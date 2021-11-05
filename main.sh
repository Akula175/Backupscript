#!/bin/bash

# Reads Input from user using flags in this order:
# "/local/directory" OR "user@server /remote/directory"

# Variable for local backup folder. Change this if you want the backup to save in a different location

LDIR=$HOME/backup

# Variable for Key. Change this if your ssh key is in a different location

KEY=~/.ssh/id_rsa.pub



## Function to archive and compress directories with tar and gzip.
## Add your directories to the variable source or change the variable to suit your script.

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
	tar -cpzf $archive -C $source . >/dev/null 2>&1 && (command sha512sum $archive > $archive.CHECKSUM)
fi


## Check if CHECKSUM is correct

if [[ -f $archive.CHECKSUM ]]; then
    command sha512sum -c $archive.CHECKSUM >/dev/null 2>&1 && echo success || echo failed
else
	echo "The archive file and checksum file doesn't match" && exit 1
fi

}



# Checks if backup Directory exists, otherwise it gets created (silent)

if [ ! -d $LDIR ]; then
    mkdir $LDIR
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
    scp -r -i $KEY $1:$2 $LDIR

fi