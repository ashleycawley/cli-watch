#!/bin/bash

TMPDIR=/home/cli-watch # No trailing slash
USERLIST=(`ls /home/ | cat`)
# Tests to see if temp directory exists and if it does not then it creates it
if [ ! -d "$TMPDIR" ]
then
    # Create temp directory and restricts permissions
    mkdir -p $TMPDIR
    chmod 600 $TMPDIR
    mkdir -p $TMPDIR/users/
    chmod 600 $TMPDIR/users/
    
fi

# Backing up the delimiter (usually a space) used by arrays to differentiate between different data in the array
SAVEIFS=$IFS

# Change the delimiter used by arrays from a space to a new line, this allows a list of users (on new lines) to be stored in to an array
IFS=$'\n'

USERARRAY=$($USERLIST)

if [ ! -d "$TMPDIR/users/" ]
then
    # Create temp directory and restricts permissions
    mkdir -p $TMPDIR
    chmod 600 $TMPDIR
fi
mkdir -p 