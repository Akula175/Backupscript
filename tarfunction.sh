#!/bin/bash

## Function to archive and compress directories
## Add your directories to the variable source or change the variable to suite your script.

tarFunction(){

source=    					    # Example $HOME/mystuff/&&/$Home/morestuff
destination=   					# Example $HOME/
filename=     					# Example "backup.tar.gz"
backup=$destination$filename

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
	echo "backup and checksum doesn't match" && exit 1
fi
}
