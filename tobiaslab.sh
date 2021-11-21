#!/bin/bash

# Reads Input from user using flags in this order:
# "/local/directory" OR "user@server /remote/directory"

# Variable for local backup folder. Change this if you want the backup to save in a different location

LDIR=$HOME/backup

##test

# Variable for Key. Change this if your ssh key is in a different location

KEY=~/.ssh/id_rsa.pub

# Variable for TEMP location

TEMP=/tmp/temp


# Checks if backup Directory exists, otherwise it gets created (silent)
# Also checks if temp Directory exists, otherwise this will also get created

if [ ! -d $LDIR ]; then
    mkdir $LDIR
if [ ! -d $TEMP ]; then
    mkdir $TEMP 
fi

fi



# Function to archive and compress directories with tar and gzip
# Source == Directory that should be zipped
# Archive == Destination Directory

tarFunction() {

    source=$1                      					   
    archive="$LDIR"/$HOSTNAME'_'$(date +"%Y-%m-%d_%H%M%S")'.tar.gz'


    ## Check if the source directory exist otherwise exit.
    ## if the source directory exist, create the archive.

    if [[ -z $source ]]; then
        echo "Source directory is empty" && exit 1
    elif [[ ! -d $source ]]; then
        echo "$source doesn't exist" && exit 1
    else
        tar -cvzf $archive -C $source . >/dev/null 2>&1 && (command sha512sum $archive > $archive.CHECKSUM)
    fi


    ## Check if CHECKSUM is correct

    if [[ -f $archive.CHECKSUM ]]; then
        command sha512sum -c $archive.CHECKSUM >/dev/null 2>&1 && echo success || echo failed
    else
        echo "The archive file and checksum file doesn't match" && exit 1
    fi

}


tarscpFunction() {

    source=$TEMP                     					   
    archive="$LDIR"/$HOSTNAME'_'$(date +"%Y-%m-%d_%H%M%S")'.tar.gz'


    # Check if the source directory exist otherwise exit
    # if the source directory exist, create the archive

    if [[ -z $source ]]; then
        echo "Source directory is empty" && exit 1
    elif [[ ! -d $source ]]; then
        echo "$source doesn't exist" && exit 1
    else
        tar -cvzf $archive -C $source . >/dev/null 2>&1 && (command sha512sum $archive > $archive.CHECKSUM)
    fi


    # Check if CHECKSUM is correct

    if [[ -f $archive.CHECKSUM ]]; then
        command sha512sum -c $archive.CHECKSUM >/dev/null 2>&1 && echo success || echo failed
    else
        echo "The archive file and checksum file doesn't match" && exit 1
    fi

}



# Checks if the "-e" flag is used. This is for encryption of a file
# Then proceeds to ask for file to encrypt and runs the encryption on input file
# $LINE == input file

if [[ $1 == "-e" ]]; then 
    cd $LDIR
    ls *tar.gz
    read -p "Which file do you want to encrypt?: " LINE
    
    if [[ ! -e "$LINE" ]]; then 
        echo "Input is not a valid file." && exit 1
    else
        gpg -c $LINE
        echo "Encryption Successful"
        rm -r $LINE
    fi
fi

# Checks if the "-d" flag is used. This is for decryption of a encrypted file

if [[ $1 == "-d" ]]; then 
    cd $LDIR
    ls *.gpg
    read -p "Which file do you want to encrypt?: " LINE
    
    if [[ ! -e "$LINE" ]]; then 
        echo "Input is not a valid file." && exit 1
    else
        gpg -o $HOSTNAME'_'$(date +"%Y-%m-%d_%H%M%S")'.tar.gz' -d $LINE
        echo "Decryption Successful"
        rm -r $LINE
    fi
fi


# Checks if input is a working Directory
# If valid Dir, begins tar

if [[ $1 =~ [/][a-z] ]] && [[ ! $1 =~ [0-9] ]]; then
    tarFunction "$1"
fi

# Checks if input is an IP addr
# If valid IP, begins scp or Rsync

if [[ $1 =~ [a-z]@[0-9] ]]; then
    echo "Entered IP address, starting scp"
    rsync -zarvh -e "ssh -i $KEY" $1:$2 $TEMP
    tarscpFunction 
    rm -rf $TEMP/*
fi