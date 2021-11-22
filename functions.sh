#!/bin/bash

###################
#                 #
#    Functions    #
#                 #
###################


helpFunction () {
## Opens a help menu if no argument is given to the script or-
# if the -h / --help flag is set.
    SCRIPTNAME=$(basename $0)
    printf "Usage:\n\n $SCRIPTNAME [options] file\n $SCRIPTNAME [options]\n\n"
    printf \
    "Options: \n\
    -h  --help                                     Shows this help\n
    -l  --local        <directory>                 Starts the backup process with tar locally
    -s  --ssh          <usr@server>:<directory>    Starts the rsync process for backing up remote files\n\
    -ss --ssh-sudo     <usr@server>:<directory>    Starts rsync process with sudo privileges, needs rsync in sudoers file on server\n
    -e  --encrypt      <directory>                 Encrypts the file
    -d  --decrypt                                  Opens a prompt where user can enter the Directory where encrypted file is located\n
    -r  --restore      <file>                      Restores files based on first arg w/o arg user gets promopted
    -rs --restore-ssh  <file>                      Restores a file to a remote server. User enters remote server and directory through prompt\n
    -c  --cron                                     Opens prompt for scheduled backups\n\n"

}



tarFunction() {
# Function to archive and compress directories with tar and gzip
# Uses the first argument added to the function in the main script as source directory.
# archive == the archived and compressed file will be placed in this directory.

    ARCHSRC=$1    # Adds the source directory used to create the archive.
    fileName="$LDIR"/$HOSTNAME'_'$(date +'(%Y-%m-%d)_') # Saves the archive in this directory with the format Hostname_(year_month_day)_(x).tar.gz
    number=0
    archive=$fileName.tar.gz
    while [ -e "$archive" ]; do
        printf -v archive '%s%03d.tar.gz' "$fileName" "$(( ++number ))"   
    done
    
    ## Check if the source directory exist otherwise exit.
    ## if the source directory exist, create the archive.

    if [[ -z $ARCHSRC ]]; then
        echo "Source directory is empty" && exit 1
    elif [[ ! -d $ARCHSRC ]]; then
        echo "$ARCHSRC doesn't exist" && exit 1
    else
        tar -cvzf $archive -C $ARCHSRC . >/dev/null 2>&1 && (command sha512sum $archive > $archive.CHECKSUM)
    fi


    ## Check if CHECKSUM is correct

    if [[ -f $archive.CHECKSUM ]]; then
        command sha512sum -c $archive.CHECKSUM >/dev/null 2>&1 && echo success || echo failed
    else
        echo "The archive file and checksum file doesn't match" && exit 1
    fi

}



encryptFunction () {
# Encrypts the file archived by tar.
# Uses tar's output file as source which is placed in the variable $archive.
# Encryption method used is symmetric OpenSSL.
    command openssl aes-256-cbc -a -salt -pbkdf2 -in $archive -out $archive.enc
    command rm $archive
    echo "Encryption Successful"
}


decryptFunction () {
### Checks if the "-d" flag is used. This is for decryption of a encrypted file

DIR_QUESTION=0
FILE_QUESTION=0
    while [[ $DIR_QUESTION -lt 1 ]]
    do
        echo -e "\nChoose the directory that containts the files you want to decrypt:"
        read -p "Directory>>  " DDIR
            if [[ -d $DDIR ]]; then
                cd $DDIR
                ENC_FILES=$(ls -A1 | grep -i .*enc)

                if [[  -z $ENC_FILES ]]; then
                   echo -e "There are no encrypted files in this directory\nChoose another directory\n"
                else
                    DIR_QUESTION=1
                    while [[ $FILE_QUESTION -lt 1 ]]
                    do
                        echo -e "\nWhich of these files do you want to decrypt?: "
                        echo -e "$ENC_FILES\n"
                        read -p "File>> " LINE
                            if [[ $LINE == *.enc ]]; then
                                command openssl aes-256-cbc -d -a -salt -pbkdf2 -in $LINE -out ${LINE%.enc}
                                echo "Decryption Successful"
                                rm $LINE
                                FILE_QUESTION=1
                            else
                                echo -e "\nSorry $LINE is not a file encrypted with OpenSSL, Please try again "
                            fi
                    done
                fi
        else
            echo -e "\n$DDIR Is not a directory or it doesn't exist', try again"
        fi
    done

}


# Restore function
# Takes the input from User and prompts user to either restore the contents of .tar file to the origin or to a custom location.
# Uses the $TEMP directory as a buffer to place files in and then copies the contents to users choice

restoreFunction () {
    clear
    tar -xpf $SDIR -C $TEMP
    cd $TEMP
    RSTR=$(cat filedir24)
    echo "Press 1 to restore to $RSTR or 2 to restore to custom Directory"
    read -p "1 or 2 & ENTER>> " -n 1
    case $REPLY in
        1 ) echo "Restoring to $RSTR"
            rm filedir24
            rsync -zarvh $TEMP/* $RSTR;;
        2 ) echo -e "\nEnter Directory to restore to: "
            read -p "Directory>> " CUSTOM
            if [[ ! -d $CUSTOM ]]; then
                echo "Input Directory is not valid, please try again." && exit 1
            else
                rm filedir24
                rsync -zarvh $TEMP/* $CUSTOM
                echo $TEMP AND $CUSTOM
            fi;;
    esac

}


# Remote restore function
# Used when the user wants to restore a backup to a remote server. In this case, the contents of "filedir24" should have user@ip.

remoterestoreFunction () {
    clear
    tar -xpf $SDIR -C $TEMP
    cd $TEMP
    RSTRSSH=$(cat filedir24)
    echo -e "Press 1 to restore to $RSTRSSH or 2 to restore to custom Directory"
    read -p "1 or 2 & ENTER>> " -n 1
    case $REPLY in
        1 ) echo "Restoring to $RSTRSSH"
            rm filedir24
            rsync -zarvh -e "ssh -i $KEY" $TEMP/* $RSTRSSH;;
        2 ) echo -e "\nEnter usr@server destination: "
            read -p "Server>> " SERVER
            echo -e "\nEnter Remote Directory"
            read -p "Remote Directory>> " RMDIR
                rm filedir24
                rsync -zarvh -e "ssh -i $KEY" $TEMP/* $SERVER:$RMDIR;;
    esac
    
}


# Cronfuntion for cronjob scheduling.
# Reads input from user and echoes the input to Cron via temporary file.

cronFuntion () {
  MYCRON=/tmp/temp/mycron
  crontab -l > $MYCRON
  DATE_CRON=0
  LOCAL_CRON=0
    while [[ $DATE_CRON -eq 0 ]]
    do
        echo "Input Minute, Hour, Day of month, Month and weekday in Crontab syntax"
        read -p "Crontime>> " CRONSYN
            if [[ $CRONSYN =~ [0-9\*/] ]]; then
                DATE_CRON=1
            else
                echo -e "\nYour input is not valid, please try again"
            fi
    done

  while [[ $LOCAL_CRON -eq 0 ]]
  do
    echo -e "\nChoose between adding an entry in crontab locally or remotely"
    echo "For locally choose[L], For remotely choose[R]"
        read -p "Crontime>> " -n 1
            case $REPLY in
                l | L)
                    CRONDIR="$PWD/main.sh --local"
                    echo -e "\nEnter Local Directory to backup: "
                    read -p "Directory>> " CRONDIR2
                    LOCAL_CRON=1

                ;;
                r | R)
                   CRONDIR="$PWD/main.sh --ssh"
                   echo -e "\nEnter USR@IP followed by Remote Directory"
                   read -p "USR@IP & Directory>> " CRONDIR2
                   LOCAL_CRON=1
                ;;
                *)
                   echo -e "\n$REPLY is not a valid answer, choose [L] or [R]"
                ;;
            esac

  done



  echo -e  "\nCronjob to be scheduled: $CRONSYN $CRONDIR $CRONDIR2"

  echo "$CRONSYN $CRONDIR $CRONDIR2" >> $MYCRON

  crontab $MYCRON

  rm $MYCRON

  }
