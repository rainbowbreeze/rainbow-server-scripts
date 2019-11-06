#!/bin/bash

# This script checks for updates to packages, and inform the server
#
#
# Part of the RainbowScripts suite


# aptitude search '~U' -F "%p"
# aptitude versions '?Upgradable'

# Show a message
output_message() {
  echo "${1}"
}

# Check what are the packages in the system to update
check_packages() {
  tmp_file1=$(mktemp)
  aptitude update
  aptitude search '~U' -F "%p" > ${tmp_file1} 2>&1

  # If there are packages to update
  if [ -s "${tmp_file1}" ]; then
    tmp_file2=$(mktemp)
    output_message "Packages to update" > ${tmp_file2}
    cat ${tmp_file1} >> ${tmp_file2}
    # forge the message and send it
    cat ${tmp_file2} | rainbow-notifyadmin.sh
    rm -f ${tmp_file2}
  fi

  rm -f ${tmp_file1}
}

check_packages