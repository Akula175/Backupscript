#!/bin/bash

# Reads Input from user using flags in this order:
# "/local/directory" OR "user@server /remote/directory"

# Variable for local backup folder (hardcoded)

whoami=USER
LDIR=/home/$USER/backup

# Checks if backup Directory exists, otherwise it gets created (silent)

if [ ! -d "/home/$USER/backup" ]; then
    echo "Does not exist, creating..."
    mkdir /home/$USER/backup
fi

# Checks if input is a working Directory
# If valid Dir, begins tar

if [[ $1 =~ [/][a-z] ]]; then
  if [ -d "$1" ]; then
    echo "Input is valid Dir, creating backup..."
    #tar ....
  else
    echo "Input is not a working Dir"
fi

# Checks if input is an IP addr
# If valid IP, begins scp or Rsync

else
  if [[ $1 =~ [a-z]@[0-9] ]]; then
    echo "Entered IP address"
    scp $1:$2 $LDIR
    
    else 
    echo "Please input IP addr or working DIR"
  
  fi 

fi