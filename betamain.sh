#!/bin/bash

WORKINGDIR=$(pwd)                # Variable for import of functions. This is where the script is located

source $WORKINGDIR/functions.sh  # Imports the functions file

LDIR=$HOME/backup            # Variable for local backup folder. Change this if you want the backup to save in a different location
KEY=~/.ssh/myprivkey         # Variable for Key. Change this if your ssh key is in a different location
TEMP=/tmp/temp               # Variable for TEMP location


# Checks if user input contains any arguments, if not, a help menu is presented.
# Help menu is stored in the *helpFunction*
if [[ ${#} -eq 0 ]]; then
helpFunction
exit 0
fi

## while user argument is not zero, check the first argument for any of the specified flags.
## if any of the listed flags matches, then take action based on the chosen flag.
while [[ ! $# -eq 0 ]]
do
    case "$1" in
        --help | -h)            # Shows the help menu and exits.
            helpFunction
            exit 0
            ;;
        --encrypt | -e)         # Activates encryption, requires an argument to the -e flag. If no argument is given then exit.'
            if [[ ! $2 ]]; then
                echo 'Please specify the directory you want to back up'
                exit 1
            else
                SDIR=$2
                FLAG_E=$1
            fi
            ;;
        --decrypt | -d)         # Activates decryption, opens a prompt where the user can specify which file to decrypt.
            FLAG_D=$1
            ;;
        --restore | -r)         # Activates restore function
            if [[ $2 ]]; then
                SDIR=$2
            fi
            FLAG_R=$1
            ;;
        --restore-ssh | -rs)   # Activates restore remote function.
            if [[ $2 ]]; then
                SDIR=$2
            fi
            FLAG_RS=$1
            ;;
        --ssh | -s)            # Activates SSH function, uses $KEY for public key and copy files remotely with rsync.
            if [[ ${2} =~ [a-z]@[0-9] ]]; then
                SSH=$2
                if [[ "$3" ]]; then
                    SDIR=$3
                    FLAG_S=$1
                fi
            else
                echo -e "\n$2 is not valid, please use the syntax username@ipadress\n\n"
                exit 1
            fi      
            ;;
        --ssh-sudo | -ss)       # Runs rsync as sudo over SSH. Requires that rsync is able to run as sudo without password on the remote host.
            if [[ $2 ]]; then
                SSH=$2
                if [[ $3 ]]; then
                    SDIR=$3
                fi
            fi
            FLAG_SS=$1
            ;;
        --local | -l)           # Used for local backup, requires the backup directory to be specified.
            if [[ "$2" ]]; then
                SDIR=$2
            fi
            FLAG_L=$1
            ;;
        --cron | -c)
            FLAG_C=$1
            ;;
    esac
    shift
done

# Checks if rsync is installed otherwise exit
rsyncCheck=$(rsync --version 2>/dev/null)
if [[ ! $rsyncCheck ]]; then
    echo "rsync is not installed"
    exit 1
fi


# Checks if backup Directory exists, otherwise it gets created (silent)
# Also checks if temp Directory exists, otherwise this will also get created

if [ ! -d $LDIR ]; then
    mkdir $LDIR
fi

if [ ! -d $TEMP ]; then
    mkdir $TEMP
fi

# Checks if input is a working Directory
# If valid Dir, begins tar

if [[ $FLAG_L || $FLAG_E ]]; then
    if [[ -z $2 ]]; then
        tarFunction $SDIR    # Runs tarFunction with the source path from the $SDIR variable.
    fi
fi


# Activates encryption if "-e" flag is set.
if [[ $FLAG_E ]]; then
    encryptFunction
fi


## Activates decryption if "-d" flag is set.
decryptFunction


# Activates Cron scheduling if "-c" flag is set.
if [[ $FLAG_C ]]; then
  cronFuntion
fi



# Creates backup with rsync through ssh.
if [[ $FLAG_S ]]; then
    echo "Entered IP address, starting scp"
    rsync -zarvh -e "ssh -i $KEY" $SSH:$SDIR $TEMP
    tarFunction $TEMP           # Runs tarFunction with the source path from the $TEMP variable.
    rm -rf $TEMP/*
fi


# Creates backup with rsync through ssh.
# Tries to run rsync with sudo privileges on the remote host.
if [[ $FLAG_SS ]]; then
    echo "Entered IP address, starting scp"
    rsync -zarvh -e "ssh -i $KEY" $SSH:$SDIR $TEMP --rsync-path="sudo rsync"
    tarFunction $TEMP           # Runs tarFunction with the source path from the $TEMP variable.
    rm -rf $TEMP/*
fi


# Restore prompt

if [[ $FLAG_R ]]; then
   if [[ ! -e "$SDIR" ]]; then
        echo "Input is not a valid file." && exit 1
    else
        restoreFunction
        rm -rf $TEMP/*
    fi
fi

echo "Finished in $SECONDS seconds"
