#!/bin/bash

###################
#                 #
#    Functions    #
#                 #  
###################



helpFunction () {
## Opens a help menu if no argument is given to the script or-
# if the -h / --help flag is set.
    SCRIPTNAME=$(basename $0)
    printf "Usage:\n\n $SCRIPTNAME [options] file\n $SCRIPTNAME [options]\n\n"
    printf \
    "Options: \n\
    -h  --help     <file>         Shows this help
    -e  --encrypt  <file>         Encrypts the file\n\n\
    -d  --decrypt  <file>         Decrypts a file based on first arg w/o arg user gets promopted\n\
    -r  --restore  <file>         Restores files based on first arg w/o arg user gets promopted\n\n\
    -s --ssh       <usr@server>   Starts the rsync process for backing up remote files\n\
    -l --local     <file>         Starts the backup process with tar locally\n\n"
}



tarFunction() {
# Function to archive and compress directories with tar and gzip
# No source directory is specified here. The source directory is added in the main script before calling this function.
# >> Specify the directory in the main script with the $ARCHSRC variable.
# archive == the archived and compressed file will be placed in this directory.
                      					  
    archive="$LDIR"/$HOSTNAME'_'$(date +'(%Y-%m-%d)'"-%H")'.tar.gz'
    #archive="$LDIR"/$HOSTNAME'_'$(date +"%Y-%m-%d")'.tar.gz'

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



encryptFunction () {
# Encrypts the file archived by tar.
# Uses tar's output file as source which is placed in the variable $archive.
# Encryption method used is symmetric OpenSSL.
    command openssl aes-256-cbc -a -salt -pbkdf2 -in $archive -out $archive.enc
    command rm $archive
    echo "Encryption Successful"
}


decryptFunction () {
### Checks if the "-d" flag is used. This is for decryption of a encrypted file

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
    tar -xpf $LDIR/$SDIR -C $TEMP
    cd $TEMP
    RSTR=$(cat filedir24)
    rm filedir24
    cp $TEMP/* $RSTR

}
