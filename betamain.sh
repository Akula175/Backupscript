#!/bin/bash

# Reads Input from user using flags in this order:
# "/local/directory" OR "user@server /remote/directory"

# Variable for local backup folder. Change this if you want the backup to save in a different location

source ./functions.sh

source=$1

LDIR=$HOME/backup

# Variable for Key. Change this if your ssh key is in a different location

KEY=~/.ssh/mypubkey.pub

# Variable for TEMP location

TEMP=/tmp/temp

# Check if Cron and rsync are installed otherwise exit
cronCheck=$(crontab -V 2>/dev/null)
rsyncCheck=$(rsync -V 2>/dev/null)

if [[ ! $cronCheck ]]; then
    echo "cron is not installed"    
    exit 1
fi

if [[ ! $rsyncCheck ]]; then
    echo "rsync is not installed"
    exit 1
fi


# Checks if backup Directory exists, otherwise it gets created (silent)
# Also checks if temp Directory exists, otherwise this will also get created

if [ ! -d $LDIR ]; then
    mkdir $LDIR
if [ ! -d $TEMP ]; then
    mkdir $TEMP 
fi

fi

## Activates encryption if "-e" flag is set.
function encryptFunction

## Activates decryption if "-d" flag is set.
function decryptFunction

# Checks if input is a working Directory
# If valid Dir, begins tar

if [[ $source =~ [/][a-z] ]] && [[ ! $source =~ [0-9] ]]; then
    tarFunction 
fi

# Checks if input is an IP addr
# If valid IP, begins scp or Rsync

if [[ $source =~ [a-z]@[0-9] ]]; then
    echo "Entered IP address, starting scp"
    rsync -zarvh -e "ssh -i $KEY" $source:$2 $TEMP
    tarscpFunction 
    rm -rf $TEMP/*
fi
