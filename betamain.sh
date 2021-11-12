#!/bin/bash

# Reads Input from user using flags in this order:
# "/local/directory" OR "user@server /remote/directory"

source ./functions.sh

LDIR=$HOME/backup            # Variable for local backup folder. Change this if you want the backup to save in a different location
KEY=~/.ssh/mypubkey.pub      # Variable for Key. Change this if your ssh key is in a different location
TEMP=/tmp/temp               # Variable for TEMP location

if [[ ${#} -eq 0 ]]; then
helpFunction
exit 0
fi

while [[ ! $# -eq 0 ]]
do
    case "$1" in
        --help | -h)
            helpFunction
            exit 0
            ;;
        --encrypt | -e)
            if [[ "$2" ]]; then
                SDIR=$2
            fi
            FLAG_E=$1 ## Activates encryption
            ;;
        --decrypt | -d)
            FLAG_D=$1 ## Activates decryption
            #shift
            ;;
        --restore | -r)
            if [[ $2 ]]; then
                SDIR=$2
            fi
            FLAG_R=$1 ## Activates restore function
            #shift
            ;;
        --ssh | -s)
            if [[ "$2" ]]; then
                SSH=$2
                if [[ "$3" ]]; then
                    SDIR=$3
                fi
            fi
            FLAG_S=$1
            ;;
        --local | -l)
            if [[ "$2" ]]; then
                SDIR=$2
            fi
            FLAG_L=$1
            ;;
    esac
    shift
done



#if [[ ! $1 -eq "" ]]; then
#    SDIR=$1                    # Variable for files to backup, reads from user input.
#fi


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

if [[ $FLAG_L ]]; then
    if [[ -z $2 ]]; then
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


if [[ $SSH =~ [a-z]@[0-9] ]]; then
    echo "Entered IP address, starting scp"
    rsync -zarvh -e "ssh -i $KEY" $SSH:$SDIR $TEMP
    ARCHSRC=$TEMP         ## ARCHSRS is used in tarFunction to declare $TEMP
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

echo "Finished in $SECONDS seconds"
