#!/bin/bash

# Pulls in variables / settings from an external config file
source `dirname $0`/config

# Arrays
# Gets a list of real users from /etc/passwd file by identifying those with a UID over 1000
USERS=(`awk -F'[/:]' '{if ($3 >= 1000 && $3 != 65534) print $1}' /etc/passwd`)

# Functions
function PERMS {
    chmod 600 $1
}

function SANITISE {
        # Searches for and sanitises in the following order: -p'Pass123' [AND] -p 'Pass123' [AND] -pPass123 [AND] --passwordPass123
        sed "s/-p'[^']*'/\-p\'XXXXXXXXXXXX\'/g" | sed "s/-p '[^']*'/\-p \'XXXXXXXXXXX\'/g" | sed 's/\-p.*[[:space:]]/\-pXXXXXXXXXXXX /g' | sed 's/\--password.*[[:space:]]/\--passwordXXXXXXXXXXXX /g'
}

# Script

# Applies bash history customisations (increases history number, parallel writing from multiple shells and instant updating)
if [ ! -f "/etc/profile.d/cli-watch-env.sh" ]
then
        echo 'HISTFILESIZE=100000
        shopt -s histappend
        export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"' > /etc/profile.d/cli-watch-env.sh
fi

# Setting up the environment
mkdir -p $WORKINGDIR
PERMS $WORKINGDIR

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
        DIFFERENCES=`diff -u0 /home/$USER/.bash_history $WORKINGDIR/$USER.bash_history_working | grep -v -E "^/home/(swb|ansible)" | grep -v "\---" | grep -v "@" | cut -c 2- | grep -v "+"`
        ROOTDIFFERENCES=`diff -u0 /root/.bash_history $WORKINGDIR/root.bash_history_working | grep -v "\---" | grep -v "@" | cut -c 2- | grep -v "+"`

        for COMMAND in `echo "$IMMEDIATECOMMANDS"`
        do
            # Tests to see if any of the recent commands include commands of interest and stores it in a file called USERNAME.hits
            echo "$DIFFERENCES" | grep -i "$COMMAND" | SANITISE >> $WORKINGDIR/$USER.hits && DIFFHIT="1"
            echo "$ROOTDIFFERENCES" | grep -i "$COMMAND" | SANITISE >> $WORKINGDIR/root.hits && ROOTDIFFHIT="1"

            # Only if the command above found hits does it re-write the log format
            if [ "$DIFFHIT" == "1" ]
            then
                # Applies cli-watch log formatting to hits found so far
                sed -i -e "s,^,`date +'%d-%m-%Y %H:%M'` `hostname` cli-watch [$USER] ,g" $WORKINGDIR/$USER.hits 2>/dev/null
            fi

	    # The same as above but for the root user
 	    if [ "$ROOTDIFFHIT" == "1" ]
            then
                # Applies cli-watch log formatting to hits found so far
                sed -i -e "s,^,`date +'%d-%m-%Y %H:%M'` `hostname` cli-watch [root] ,g" $WORKINGDIR/root.hits 2>/dev/null
           fi

            # Checks to see if there are any hits to report and if there is it dispatches the alert email
            if [ -f "$WORKINGDIR/$USER.hits" ] && [ -s "$WORKINGDIR/$USER.hits" ]
            then
                # Email / Alerting routine, this can be easily switched between logging to a file or dispatch a report via email
                cat $WORKINGDIR/$USER.hits | mail -s "CLI-WATCH Report" $EMAILADDRESS

                # Cleaning temporary report of hits
                rm -f $WORKINGDIR/$USER.hits

            fi

	    if [ -f "$WORKINGDIR/root.hits" ] && [ -s "$WORKINGDIR/root.hits" ]
            then
                # Email / Alerting routine, this can be easily switched between logging to a file or dispatch a report via email
                cat $WORKINGDIR/root.hits | mail -s "CLI-WATCH Report" $EMAILADDRESS

                # Cleaning temporary report of hits
                rm -f $WORKINGDIR/root.hits

            fi

        done

        # Cleans out working copy
        rm -f $WORKINGDIR/$USER.bash_history_working
        rm -f $WORKINGDIR/root.hits

        # Copies the users bash history to the working directory
        cp /home/$USER/.bash_history $WORKINGDIR/$USER.bash_history_working
        cp /root/.bash_history $WORKINGDIR/root.bash_history_working
        PERMS $WORKINGDIR/$USER.bash_history_working
        PERMS $WORKINGDIR/root.bash_history_working

    else

        # Copy the users bash history to the working directory
        cp /home/$USER/.bash_history $WORKINGDIR/$USER.bash_history_working
        cp /root/.bash_history $WORKINGDIR/root.bash_history_working
        PERMS $WORKINGDIR/$USER.bash_history_working
        PERMS $WORKINGDIR/root.bash_history_working

    fi
    
    # Cleans up any empty USER.hits files
    rm -f $WORKINGDIR/$USER.hits
    rm -f $WORKINGDIR/root.hits

done

exit 0
