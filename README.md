# cli-watch
New re-write of command-monitor

# Instructions

Notes

## Scheduling
cli-watch is designed to be run once a minute via the crontab. A full path to the script should be specified as follows:

```* * * * * bash /root/cli-watch/cli-watch.sh```

## Dev Notes
* Add filtering of swb and ansible users
* Add checking of root user's .bash_history

## Completed Improvements
* Externalise some variables in to config file
