# rainbow-server-scripts
Various scripts to manage my Linux homelab servers.
- Perform a simple backup of the system via rsync
- Check if a list of hosts are up'nd running
- Send a message via Telegram
- Send a message via a specialized bot
- Perform system upgrade
- Notify for an SSH login

## How to install
```
wget https://raw.githubusercontent.com/rainbowbreeze/rainbow-server-scripts/master/scripts/rainbow-updater  
chmod +x rainbow-updater  
./rainbow-updater  
rm rainbow-updater 
```


## Local debug / execution of the scripts
In order to debug locally the scripts, without installing them, all the config vars can be written in file ```./conf/debug-rainbowscripts.conf``` - Scripts will automatically pick them up.  


## NOTES

Script conventions
- Why ${} to refer to var name? To refer to the precise var name, when concatenating with other strings: http://www.compciv.org/topics/bash/variables-and-substitution/


### Cronjobs
In order to run correctly, cron jobs have to call the exact path of the other rainbow scripts they need to execute.  
And, by default, all rainbowscripts are installed under ```/usr/bin/local```.  
Alternative to test: set the PATH var inside the cron.d file. Examples in /etc/crontab and [here](https://www.cyberciti.biz/faq/how-do-i-add-jobs-to-cron-under-linux-or-unix-oses/).    

To redirect the output of the command in a file, add this after the command
```
>> /var/log/cronrun 2>&1
```
Example
```
30 07 * * * root /usr/local/bin/rainbow-backupnas > >>/var/log/rainbow-backupnas-cron 2>&1
```
