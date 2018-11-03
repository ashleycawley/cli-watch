#!/bin/bash

# Variables
WORKINGDIR=/tmp/cli-watch # No trailing slash
IMMEDIATECOMMANDS=immediate-commands.txt

# Arrays
USERS=(`ls /home`)

# Functions

# Script

# Setting up the environment
mkdir -p $WORKINGDIR
chmod 600 $WORKINGDIR

for USER in ${USERS[*]}
do

    # If a user does not have a .bash_history file in their home folder then this creates an empty one, this is required for first-run logic to work
    if [ ! -f "/home/$USER/.bash_history" ]
    then
        touch /home/$USER/.bash_history
        chown $USER:$USER /home/$USER/.bash_history
    fi

    # Tests to see if we have a working copy of the user's bash history
    if [ -f "$WORKINGDIR/$USER.bash_history_working" ]
    then

        # Tests for differences between users bash history and our working copy, it saves new/differences into variable $DIFFERENCES
        DIFFERENCES=`diff -u0 /home/$USER/.bash_history $WORKINGDIR/$USER.bash_history_working | grep -v "\---" | grep -v "@" | cut -c 2- | grep -v "+"`

        for COMMAND in $IMMEDIATECOMMANDS
        do
            # Tests to see if any of the recent commands include commands of interest and stores the results in $CLIHITS
            echo "$DIFFERENCES" | grep -i "$COMMAND" >> $WORKINGDIR/$USER.hits

            # Applies cli-watch log formatting to hits found so far
            sed -i -e "s,^,`date +'%d-%m-%Y %H:%M'` `hostname` cli-watch [$USER] ,g" $WORKINGDIR/$USER.hits 2>/dev/null

        done

        # Cleans out working copy
        rm -f $WORKINGDIR/$USER.bash_history_working

        # Copies the users bash history to the working directory
        cp /home/$USER/.bash_history $WORKINGDIR/$USER.bash_history_working

        # Checks to see if there are any hits to report and if there is it dispatches the alert email
        if [ -f "$WORKINGDIR/$USER.hits" ]
        then
            # EMAIL ROUTINE WOULD GO HERE - This is just mimicking a dispatched email
            cat $WORKINGDIR/$USER.hits > email.eml # mail -s "CLI-WATCH Report" $EMAILADDRESS
        else
            exit 0
        fi


    else

    # Copies the users bash history to the working directory
    echo "Taking initial copy of user's .bash_history file" # DEBUGGING
    cp /home/$USER/.bash_history $WORKINGDIR/$USER.bash_history_working

    # echo "Exiting..." # DEBUGGING
    # exit 0

        fi


    #if [ `md5sum /home/ashley/.bash_history` == `md5sum $WORKINGDIR/.bash_history_working` ]
    #then

        #echo "User's .bash_history matches our working copy so no further work is needed, exiting..." # DEBUGGING
        #exit 0

    #else

 
    #fi



done




exit 0
