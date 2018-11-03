#!/bin/bash

# Variables
WORKINGDIR=/tmp/cli-watch # No trailing slash
IMMEDIATECOMMANDS=immediate-commands.txt

# Arrays
USERS=(`ls /home`)

# Functions

# Script

for $USER in ${USERS[*]}
do

    if [ -f "$WORKINGDIR/$USER.bash_history_working" ]
    then

        # Tests for differences between users bash history and our working copy, it saves new/differences into variable $DIFFERENCES
        DIFFERENCES=`diff -u0 /home/$USER/.bash_history $WORKINGDIR/.$USER.bash_history_working | grep -v "\---" | grep -v "@" | cut -c 2- | grep -v "+"`

        for COMMAND in $IMMEDIATECOMMANDS
        do
            # Tests to see if any of the recent commands include commands of interest and stores the results in $CLIHITS
            echo "$DIFFERENCES" | grep -i "$COMMAND" >> $WORKINGDIR/$USER.hits

            # Applies cli-watch log formatting to hits found so far
            sed -i -e "s,^,`date +'%d-%m-%Y %H:%M'` `hostname` cli-watch [$USER] ,g" $WORKINGDIR/$USER.hits 2>/dev/null

        done

    # Cleans out working copy
    rm -f $WORKINGDIR/.$USER.bash_history_working

    # Copies the users bash history to the working directory
    cp /home/$USER/.bash_history $WORKINGDIR/.$USER.bash_history_working


    ### Build logic to see if there is anything to report and if there is mail it off















    else

    # Copies the users bash history to the working directory
    echo "Taking initial copy of user's .bash_history file" # DEBUGGING
    cp /home/$USER/.bash_history $WORKINGDIR/$USER.bash_history_working

    echo "Exiting..." # DEBUGGING
    exit 0

        fi


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



done




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