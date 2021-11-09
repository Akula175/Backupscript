cronChk () {
cronCheck=$(crontab -V 2>/dev/null)

## checks if cron and rsync exist otherwise exit.

if [[ ! $cronCheck ]]; then
    echo "cron is not installed"    
    exit 1
fi
}

rsyncChk () {
rsyncCheck=$(rsync -V 2>/dev/null)
if [[ ! $rsyncCheck ]]; then
    echo "rsync is not installed"
    exit 1
fi
}



# Function to archive and compress directories with tar and gzip
# Source == Directory that should be zipped
# Archive == Destination Directory

tarFunction() {

    source=$source                      					   
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

encryptFunction () {


# Checks if the "-e" flag is used. This is for encryption of a file
# Then proceeds to ask for file to encrypt and runs the encryption on input file
# $LINE == input file

if [[ $source == "-e" ]]; then 
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

}
# Checks if the "-d" flag is used. This is for decryption of a encrypted file

decryptFunction () {

if [[ $source == "-d" ]]; then 
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
