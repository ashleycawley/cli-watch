# cli-watch

A utility that monitors user's .bash_history files for commands of interest that you specify. If a particular command is used then a email notifcation is dispatched.



# Instructions


In order for this system to work in good speed it is suggested that a few adjustments are made to the user's .bashrc file or a global equivalent. The suggested changes below only improve the speed, effeciency and reliability of which the user's bash history is saved, so they are useful in themselves whether you choose to use the cli-watch utility or not.

vim ~/.bashrc

```
HISTFILESIZE=100000
shopt -s histappend
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
```

source ~/.bashrc



## Scheduling
cli-watch is designed to be run once a minute via the crontab. A full path to the script should be specified as follows:

```* * * * * bash /root/cli-watch/cli-watch.sh```

## Suggested Command Inclusions (anti-tampering measures)
```
history -c

```

## Dev Notes
* Sanitise the following pattern: -p 'my_pass_here'
* Look for additional password use patterns in real life .bash_history files to build additional sanitisation rules

## Completed Improvements
* Create a sanatise function to filter out passwords from strings like:
-p'PaSsWoRd'
* Detects if global adjustments have been made to improve bash history effeciency if not it makes them at /etc/profile.d/cli-watch-env.sh
* Find a better way of finding a list of users (other than ls /home)
* Add checking of root user's .bash_history
* Add filtering of swb and ansible users
* Externalise some variables in to config file
