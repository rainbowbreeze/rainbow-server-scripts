#!/bin/bash

# This script checks for updates to packages, and inform the server
#
#
# Part of the RainbowScripts suite

# aptitude search '~U' -F "%p"

# Get the packages to update
packages=$(aptitude search '~U' -F "%p")

# aptitude versions '?Upgradable'

# If there are packages to update
if [ -z "${packages}" ]; then
  # forge the message and send it
  message = "There are packages to upgrade\n${pagkages}"
  rainbow-notifyadmin.sh \"${message}\"
fi
