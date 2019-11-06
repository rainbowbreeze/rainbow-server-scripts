#!/bin/bash

# This script checks for updates to packages, and inform the server
#
#
# Part of the RainbowScripts suite

# aptitude search '~U' -F "%p"
# aptitude versions '?Upgradable'

tmpfile1=$(mktemp)
aptitude search '~U' -F "%p" > ${tmpfile1} 2>&1

# If there are packages to update
if [ -s "${tmpfile1}" ]; then
  tmpfile2=$(mktemp)
  echo "Packages to update" > ${tmpfile2}
  cat ${tmpfile1} >> ${tmpfile2}
  # forge the message and send it
  cat ${tmpfile2} | rainbow-notifyadmin.sh
  rm -f ${tmpfile2}
fi

rm -f ${tmpfile1}