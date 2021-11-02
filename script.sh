#!/bin/bash

# Reads Input from user

echo "What do you want to back up?: "
read -r VAL

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
    echo "Input Remote DIR and local DIR: "
    read -r RDIR LDIR
    scp $VAL:$RDIR $LDIR
    
  else 
    echo "Please input IP addr or working DIR"
  
  fi 

fi
