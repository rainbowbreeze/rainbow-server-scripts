#!/bin/bash

# This scrips upgrade the system
#
#
# Part of the RainbowScripts suite


# aptitude search '~U' -F "%p"
# aptitude versions '?Upgradable'

# Check for root execution
check_for_root() {
  if [ $EUID -ne 0 ]; then
    output_message "This script must be run as root" 
    exit 1
  fi
}

# Show a message
output_message() {
  echo ${1}
}

# Check what are the packages in the system to update
check_packages() {
  local tmp_file1=$(mktemp)
  aptitude update
  aptitude search '~U' -F "%p" > ${tmp_file1} 2>&1

  # If there are packages to update
  if [ -s "${tmp_file1}" ]; then
    output_message "Notify about packages to upgrade..."
    local tmp_file2=$(mktemp)
    echo "Packages to update" > ${tmp_file2}
    cat ${tmp_file1} >> ${tmp_file2}
    # forge the message and send it
    cat ${tmp_file2} | rainbow-notifyadmin.sh
    rm -f ${tmp_file2}
    upgrade_packages
  else
    output_message "No packages to upgrade"
  fi

  rm -f ${tmp_file1}
}

upgrade_packages() {
  output_message "Upgrading packages..."
  local tmp_file=$(mktemp)
  echo "Upgrading the system" > ${tmp_file}
  aptitude -y full-upgrade -q=2 >> ${tmp_file} 2>&1
  cat ${tmp_file} | rainbow-notifyadmin.sh
  rm -f ${tmp_file}
  output_message " System upgrade done!"
}


# Check if the command was launched using root permissions
check_for_root
check_packages