#!/bin/bash

## Function to archive and compress directories with tar and gzip.
## Add your directories to the variable source or change the variable to suite your script.

tarFunction() {

source=    					# Example $HOME/mystuff/
destination=  					# Example $HOME/
filename=     					# Example "backup.tar.gz"
backup=$destination$filename


## Check if the source and destination directories exists otherwise exit.
if [[ ! -d $source ]]; then
    echo "$source doesn't exist" && exit 1
fi

if [[ ! -d $destination ]]; then
    echo "$destination doesn't exist" && exit 1
fi

# Create a backup if the backup file doesn't already exist.

if [[ -f $backup ]]; then
	echo "The file $backup already exists...exiting"
	exit 1

else
	tar -czf $backup $source >/dev/null 2>&1 && (command sha512sum $backup > $backup.CHECKSUM)

fi

## Check if CHECKSUM is correct

if [[ -f $backup.CHECKSUM ]]; then
	command sha512sum -c $backup.CHECKSUM

else
	echo "backup file and checksum file doesn't match" && exit 1
fi
}
