#!/bin/bash

## Function to archive and compress directories with tar and gzip.
## Add your directories to the variable source or change the variable to suite your script.

tarFunction() {

source=$HOME/hey/    					    # Example $HOME/mystuff/
destination=$HOME/   					# Example $HOME/
filename=archive.tar.gz     					# Example "archive.tar.gz"
archive=$destination$filename


## Check if the source and destination directories exists otherwise exit.

if [[ -z $source ]]; then
    echo "Source directory is empty" && exit 1
elif [[ -z $destination ]]; then 
    echo "Destination directory is empty" && exit 1
elif [[ ! -d $source ]]; then
    echo "$source doesn't exist" && exit 1
elif [[ ! -d $destination ]]; then
    echo "$destination doesn't exist" && exit 1
fi

# Create an archive if the archive file doesn't already exist.

if [[ -f $archive ]]; then
	echo "The file $archive already exists...exiting" && exit 1

else
	tar -czf $archive $source >/dev/null 2>&1 && (command sha512sum $archive > $archive.CHECKSUM)

fi
echo "hey"
## Check if CHECKSUM is correct

if [[ -f $archive.CHECKSUM ]]; then
	command sha512sum -c $archive.CHECKSUM

else
	echo "The archive file and checksum file doesn't match" && exit 1
fi
}
