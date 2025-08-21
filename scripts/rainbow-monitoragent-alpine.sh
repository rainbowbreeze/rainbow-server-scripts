#!/bin/sh
echo $$ > /run/rainbow-monitoragent.pid  # Store the PID of this process
/usr/bin/python3 /usr/local/bin/rainbow-monitoragent.py

