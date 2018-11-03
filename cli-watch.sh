#!/bin/bash

# Variables
WORKINGDIR=/tmp/cli-watch # No trailing slash

# Functions

# Script

if [ -f "$WORKINGDIR/.bash_history_working" ]
then

    # Continue script code

else

# Copies the users bash history to the working directory
echo "Taking initial copy of user's .bash_history file and then exiting..." # DEBUGGING
cp /home/ashley/.bash_history $WORKINGDIR/.bash_history_working
exit 0

    if [ `md5sum /home/ashley/.bash_history` == `md5sum $WORKINGDIR/.bash_history_working` ]
    then

        echo "User's .bash_history matches our working copy so no further work is needed, exiting..." # DEBUGGING
        exit 0

    else

    # Differences found between user's .bash_history and our working copy
    # Contiune with script to compare changes and alert people

    # Extract only the differences
    # Scan differences for commands of interest
        # if no hits then exit
        # if hits then proceed with format parsing and alerting

    fi

fi









exit 0

#############################################


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