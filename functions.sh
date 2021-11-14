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
    -h  --help     <file>         Shows this help
    -e  --encrypt  <file>         Encrypts the file\n\n\
    -d  --decrypt  <file>         Decrypts a file based on first arg w/o arg user gets promopted\n\
    -r  --restore  <file>         Restores files based on first arg w/o arg user gets promopted\n\n\
    -s --ssh       <usr@server>   Starts the rsync process for backing up remote files\n\
    -l --local     <file>         Starts the backup process with tar locally\n\n"
}



tarFunction() {
# Function to archive and compress directories with tar and gzip
# Uses the first argument added to the function in the main script as source directory.
# archive == the archived and compressed file will be placed in this directory.
    
    ARCHSRC=$1    # Adds the source directory used to create the archive.
    archive="$LDIR"/$HOSTNAME'_'$(date +'(%Y-%m-%d)'"-%H")'.tar.gz' # Saves the archive in this directory with the format Hostname_(year_month_day)-hour.tar.gz
    #archive="$LDIR"/$HOSTNAME'_'$(date +"%Y-%m-%d")'.tar.gz'

    ## Check if the source directory exist otherwise exit.
    ## if the source directory exist, create the archive.

    if [[ -z $ARCHSRC ]]; then
        echo "Source directory is empty" && exit 1
    elif [[ ! -d $ARCHSRC ]]; then
        echo "$ARCHSRC doesn't exist" && exit 1
    else
        echo $ARCHSRC > $ARCHSRC/./filedir24
        tar -cvzf $archive -C $ARCHSRC . >/dev/null 2>&1 && (command sha512sum $archive > $archive.CHECKSUM)
        rm $ARCHSRC/./filedir24
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

if [[ $FLAG_D ]]; then 

DIR_QUESTION=0
FILE_QUESTION=0

    while [[ $DIR_QUESTION -lt 1 ]]
    do
    echo -e "\nChoose the directory that containts the files you want to encrypt:"
    read -p "Directory>>  " DDIR
        if [[ -d $DDIR ]]; then
            cd $DDIR
            ENC_FILES=$(ls -A1 | grep -i .*enc)   
#            echo $ENC_FILES          
                if [[  -z $ENC_FILES ]]; then
                   echo -e "There are no encrypted files in this directory\nChoose a different directory\n"
                else
                    DIR_QUESTION=1
                    while [[ $FILE_QUESTION -lt 1 ]]
                    do
                        echo -e "\nWhich of these files do you want to encrypt?: "
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
            echo "$DDIR Is not a directory, try again"     
        fi
    
    done


fi

}

# Restore function

restoreFunction () {
    tar -xpf $LDIR/$SDIR -C $TEMP
    cd $TEMP
    RSTR=$(cat filedir24)
    rm filedir24
    cp $TEMP/* $RSTR

}
