#!/bin/bash

# Reads Input from user using flags in this order:
# "/local/directory" OR "user@server /remote/directory"

# Variable for local backup folder. Change this if you want the backup to save in a different location

LDIR=$HOME/backup

# Variable for Key. Change this if your ssh key is in a different location

KEY=~/.ssh/id_rsa.pub


# Checks if backup Directory exists, otherwise it gets created (silent)

if [ ! -d $LDIR ]; then
    mkdir $LDIR
fi

# Checks if input is a working Directory
# If valid Dir, begins tar

if [[ $1 =~ [/][a-z] ]] && [[ ! $1 =~ [0-9] ]]; then
  if [ -d "$1" ]; then
    echo "Input is valid Directory, creating backup..."
    #tar ....
  else
    echo "$1 is not a working Directory" && exit 1
fi

# Checks if input is an IP addr
# If valid IP, begins scp or Rsync

else
  if [[ $1 =~ [a-z]@[0-9] ]]; then
    echo "Entered IP address, starting scp"
    scp -r -i $KEY $1:$2 $LDIR
    
    else 
    echo "Please input IP addr or working DIR" && exit 1
  
  fi 

fi