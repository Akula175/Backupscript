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

    ARCHSRC=$SDIR                      					   
    archive="$LDIR"/$HOSTNAME'_'$(date +"%Y-%m-%d_%H-%M")'.tar.gz'
    echo $source


    ## Check if the source directory exist otherwise exit.
    ## if the source directory exist, create the archive.

    if [[ -z $ARCHSRC ]]; then
        echo "Source directory is empty" && exit 1
    elif [[ ! -d $ARCHSRC ]]; then
        echo "$ARCHSRC doesn't exist" && exit 1
    else
        echo $ARCHSRC > $ARCHSRC/./filedir24
        tar -cvzf $archive -C $ARCHSRC . >/dev/null 2>&1 && (command sha512sum $archive > $archive.CHECKSUM)
        rm $ARCHSRC/./filedir24
    fi


    ## Check if CHECKSUM is correct

    if [[ -f $archive.CHECKSUM ]]; then
        command sha512sum -c $archive.CHECKSUM >/dev/null 2>&1 && echo success || echo failed
    else
        echo "The archive file and checksum file doesn't match" && exit 1
    fi

}


tarscpFunction() {

    source=$SDIR                     					   
    archive="$LDIR"/$HOSTNAME'_'$(date +"%Y-%m-%d_%H%M%S")'.tar.gz'


    # Check if the source directory exist otherwise exit
    # if the source directory exist, create the archive

    if [[ -z $SDIR ]]; then
        echo "Source directory is empty" && exit 1
    elif [[ ! -d $SDIR ]]; then
        echo "$SDIR doesn't exist" && exit 1
    else
        tar -cvzf $archive -C $SDIR . >/dev/null 2>&1 && (command sha512sum $archive > $archive.CHECKSUM)
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
encryptFunction () {


if [[ $FLAG_E ]]; then 
    command openssl aes-256-cbc -a -salt -pbkdf2 -in $archive -out $archive.enc
    command rm $archive
    echo "Encryption Successful"

fi
}

### Checks if the "-d" flag is used. This is for decryption of a encrypted file
decryptFunction () {


if [[ $FLAG_D ]]; then 
    cd $LDIR
    ls *.enc
    read -p "Which file do you want to encrypt?: " LINE
    
    if [[ ! -e "$LINE" ]]; then 
        echo "Input is not a valid file." && exit 1
    else
        command openssl aes-256-cbc -d -a -salt -pbkdf2 -in $LINE -out ${LINE%.enc}
        echo "Decryption Successful"
        rm $LINE
    fi
fi

}

# Restore function

restoreFunction () {
    tar -xpf $LDIR/$LINE2 -C $TEMP
    cd $TEMP
    RSTR=$(cat filedir24)
    rm filedir24
    cp $TEMP/* $RSTR


}



