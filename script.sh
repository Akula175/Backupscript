#!/bin/bash

# Reads Input from user

echo "What do you want to back up?: "
read -r VAL

# Variabel för backupmapp

whoami=USER
LDIR=/home/$USER/backup

# Checks if backup Directory exists, otherwise it gets created (silent)

if [ ! -d "/home/$USER/backup" ]; then
    mkdir /home/$USER/backup
fi

# Checks if input is a working Directory
# If valid Dir, begins tar

if [[ $VAL =~ [/]+[a-z] ]]; then
  if [ -d "$VAL" ]; then
    echo "Input is valid Dir, creating backup..."
    #tar ....
  else
    echo "Input is not a working Dir"
fi

# Checks if input is an IP addr
# If valid IP, begins scp

else
  if [[ $VAL =~ [Aa-Zz]+[@]+[0-9] ]]; then
    echo "Entered IP address"
    echo "Input Remote DIR: "
    read -r RDIR
    scp $VAL:$RDIR $LDIR
    
  else 
    echo "Please input IP addr or working DIR"
  
  fi 

fi
