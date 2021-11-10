#!/bin/bash

###################
#                 #
#    Functions    #
#                 #  
###################





# Function to archive and compress directories with tar and gzip
# Source == Directory that should be zipped
# Archive == Destination Directory

tarFunction() {

    source=$BFILES                      					   
    archive="$LDIR"/$HOSTNAME'_'$(date +"%Y-%m-%d_%H%M%S")'.tar.gz'


    ## Check if the source directory exist otherwise exit.
    ## if the source directory exist, create the archive.

    if [[ -z $BFILES ]]; then
        echo "Source directory is empty" && exit 1
    elif [[ ! -d $BFILES ]]; then
        echo "$BFILES doesn't exist" && exit 1
    else
        tar -cvzf $archive -C $BFILES . >/dev/null 2>&1 && (command sha512sum $archive > $archive.CHECKSUM)
    fi


    ## Check if CHECKSUM is correct

    if [[ -f $archive.CHECKSUM ]]; then
        command sha512sum -c $archive.CHECKSUM >/dev/null 2>&1 && echo success || echo failed
    else
        echo "The archive file and checksum file doesn't match" && exit 1
    fi

}


tarscpFunction() {

    source=$BFILES                     					   
    archive="$LDIR"/$HOSTNAME'_'$(date +"%Y-%m-%d_%H%M%S")'.tar.gz'


    # Check if the source directory exist otherwise exit
    # if the source directory exist, create the archive

    if [[ -z $BFILES ]]; then
        echo "Source directory is empty" && exit 1
    elif [[ ! -d $BFILES ]]; then
        echo "$BFILES doesn't exist" && exit 1
    else
        tar -cvzf $archive -C $BFILES . >/dev/null 2>&1 && (command sha512sum $archive > $archive.CHECKSUM)
    fi


    # Check if CHECKSUM is correct

    if [[ -f $archive.CHECKSUM ]]; then
        command sha512sum -c $archive.CHECKSUM >/dev/null 2>&1 && echo success || echo failed
    else
        echo "The archive file and checksum file doesn't match" && exit 1
    fi

}



# Checks if the "-e" flag is used. This is for encryption of a file
# Then proceeds to automatically encrypts the file created by tarFunction.
# An interactive shell opens where the user is required to set a password

encryptFunction () {
if [[ $FLAG_E ]]; then 
    command gpg -o $archive.enc --symmetric --cipher-algo aes256 $archive
    echo "Encryption Successful"
else
    echo "Something went wrong...exiting" && exit 1
fi

}


### Checks if the "-d" flag is used. This is for decryption of a encrypted file
decryptFunction () {

if [[ $BFILES == "-d" ]]; then 
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

}
