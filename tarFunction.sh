#!/bin/bash

## Function to archive and compress directories with tar and gzip.
## Add your directories to the variable source or change the variable to suit your script.

tarFunction() {

source=                        					    # Example $HOME/mystuff/
archive=./$HOSTNAME'_'$(date +"%Y-%m-%d_%H%M%S")'.tar.gz'


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
