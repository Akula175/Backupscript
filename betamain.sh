#!/bin/bash

# Reads Input from user using flags in this order:
# "/local/directory" OR "user@server /remote/directory"

source ./functions.sh

LDIR=$HOME/backup            # Variable for local backup folder. Change this if you want the backup to save in a different location
KEY=~/.ssh/mypubkey.pub      # Variable for Key. Change this if your ssh key is in a different location
TEMP=/tmp/temp               # Variable for TEMP location


## Checks if -e flag or -d flag are set from user input.
while getopts "edr" FLAGS
do
    case $FLAGS in
        e) 
            FLAG_E=$1 ## Activates encryption
            shift
            ;;
        d) 
            FLAG_D=$1 ## Activates decryption
            shift
            ;;
        r)
            FLAG_R=$1 ## Activates restore function
            shift
            ;;
    esac
done


SDIR=$1                    # Variable for files to backup, reads from user input.


# Check if Cron and rsync are installed otherwise exit
cronCheck=$(crontab -V 2>/dev/null)
rsyncCheck=$(rsync -V 2>/dev/null)

#if [[ ! $cronCheck ]]; then
#    echo "cron is not installed"    
#    exit 1
#fi#

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

if [[ ! $FLAG_D && ! $FLAG_R ]]; then
    if [[ $SDIR =~ [/][a-z] ]] && [[ ! $SDIR =~ [0-9] ]]; then
        ARCHSRC=$SDIR
        tarFunction 
    fi
fi


## Activates encryption if "-e" flag is set.
encryptFunction


## Activates decryption if "-d" flag is set.
decryptFunction

# Checks if input is an IP addr
# If valid IP, begins scp or Rsync

if [[ $2 =~ [a-z]@[0-9] ]]; then
    echo "Entered IP address, starting scp"
    rsync -zarvh -e "ssh -i $KEY" $2:$SDIR $TEMP
    ARCHSRCH=$TEMP
    tarFunction 
    rm -rf $TEMP/*
fi
 

# Restore prompt

if [[ $FLAG_R ]]; then 
    cd $LDIR
    ls *.gz
    read -p "Which file do you want to restore?: " LINE2
    
    if [[ ! -e "$LINE2" ]]; then 
        echo "Input is not a valid file." && exit 1
    else
        restoreFunction
        rm -rf $TEMP/*
    fi
fi
