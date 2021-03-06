# cli-watch

A utility that proactively monitors the bash history of all users on the system, it watches for commands of interest (commands specified by you). If one of those commands are used then an email notifcation is dispatched with a log of what command was executed, by who and when.

Enter commands that you would like to monitor within the following file:
```commands.txt```

If you entered the command ```mysqldump``` into that file and cli-watch detected someone using that program then the email report you recieve would contain the full command, an example the email report may look something like this:

```16-11-2018 13:46 watched-server.com cli-watch [gerry] mysqldump --all-databases --quick > db_export.sql```

The script is designed to be used by the root user and triggered by a scheduled task (CRON) once a minute or less frequent if you choose.


# Instructions

Clone this repository:
```git clone https://github.com/ashleycawley/cli-watch.git /root/cli-watch/```

Move into the folder:
```cd /root/cli-watch/```

Copy the Template config into position:
```cp config-template config```

Edit the 'config' file so that it contains your email address:
```vi config```

Populate the ```commands.txt``` file with commands your interested in monitoring, here are some ideas:

'''rm -fr
passwd
mysqldump
history -c'''

Schedule the script to run once a minute by running:
```crontab -e```

And enter in the following line at the end of the file and save:
```* * * * * bash /root/cli-watch/cli-watch.sh```

### You are all setup and the system is running!

#### Testing cli-watch
If you are relying on this for security notifications then I would advise testing your systems ability to reliably dispatch an email to you. You could do this by adding in a benine command into the ```commands.txt``` file, something like ```whoami```. Then you can intentionally use that command on the system and watch out for an email notification at the email address you specified in the config file.

If you are not receiving email then you could try checking you have the required software to send email, on a lot of Linux systems the following may help:

```yum install mailx```

```sudo apt-get install mailx```

Or seek guidence on the relevant mail sending program for your OS distrubution.

---
### cli-watch Improves your system's bash history recording, here's how...

Bash history is not configured optimially out of the box, it can fail to save commands if connections are dropped or users use multiple windows, this script changes a few global settings to do with bash history, it does this by saving a file at:

```/etc/profile.d/cli-watch-env.sh```

It applies the following adjustments:

```
HISTFILESIZE=100000
shopt -s histappend
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
```
In short those do the following things:
- Increases the number of commands which are remembered by bash's history.
- Writes commands to the history immediately as oppose later which is the norm.
- Prevents the history from being lost due to disconnection or multiple terminals being used.
- Prevents users from clearing their history and hiding their tracks with ```history -c```

---

## Dev Notes
* Have a theory that if no standard users exist in /etc/passwd (+1000 UID) then it may exit prematurely and not monitor root user
* Mute errors from grep by redirecting standard errors to dev null to avoid emails being dispatched like:
Usage: grep [OPTION]... PATTERN [FILE]...
Try 'grep --help' for more information.
* Add check for immediate-commands.txt if it doesn't exist create empty file
* Check to see if mailx package is installed and if not then offer to install?
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
