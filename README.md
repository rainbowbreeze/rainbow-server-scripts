# rainbow-server-scripts
Various scripts to manage my Linux server machines

## How to install
wget https://raw.githubusercontent.com/rainbowbreeze/rainbow-server-scripts/master/scripts/rainbow-updater.sh  
chmod +x rainbow-updater.sh  
./rainbow-updater.sh  
rm rainbow-updater.sh  


## NOTES

Script conventions
- Why ${} to refer to var name? To refer to the precise var name, when concatenating with other strings: http://www.compciv.org/topics/bash/variables-and-substitution/


### Cron.d debug

To redirect the output of the command in a file, add this after the command
```
>>/var/log/cronrun 2>&1
```
Example
```
30 07 * * * root /usr/local/bin/rainbow-backupnas.sh > >>/var/log/rainbow-backupnas-cron 2>&1
```
