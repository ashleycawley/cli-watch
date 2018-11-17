# cli-watch

A utility that proactively monitors the bash history of all users on the system, it watches for commands of interest (commands specified by you). If one of those commands are used then an email notifcation is dispatched with a log of what command was executed, by who and when.

Enter commands that you would like to cli-watch to monitor within the following file:
```immediate-commands.txt```

If you entered the command ```mysqldump``` into that file and cli-watch detected someone using it then the email report you recieve would contain the full command, as an example the email report may look something like this:

```16-11-2018 13:46 sensative-server.com cli-watch [gerry] mysqldump --all-databases --quick > db_export.sql```

The script is designed to be used by the root user and triggered by a scheduled task (CRON) once a minute.


# Instructions

Clone this repository:
```git clone https://github.com/ashleycawley/cli-watch.git /root/cli-watch/```

Move into the folder:
```cd /root/cli-watch/```

Copy the Template config into position:
```cp config-template config```

Edit the 'config' file appropriate by following the instructions/comments in the file:
```vi config```

Schedule the script to run once a minute by running:
```crontab -e```

And enter in the following line at the end of the file and save:
```* * * * * bash /root/cli-watch/cli-watch.sh```

Bash history is not configured optimially out of the box, it can fail to save commands if connections are dropped or users use multiple windows, this script changes a few global settings to do with bash history, it does this by saving a file at:

```/etc/profile.d/cli-watch-env.sh```

It applies the following adjustments:

```
HISTFILESIZE=100000
shopt -s histappend
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
```
In short those do the following things: it increases the number of commands which are remembered by bash's history and it writes commands to the history immediately to prevent he history from being lost (which it is quite often on default setups).



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
