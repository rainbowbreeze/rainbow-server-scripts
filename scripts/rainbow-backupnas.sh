#!/bin/bash

# This scrips performs a backup to a rsync server
#
#
# Part of the RainbowScripts suite


# Show a message
output_message() {
  echo "${1}"
}

# Check for root execution
check_for_root() {
  if [[ $EUID -ne 0 ]]; then
    output_message "This script must be run as root" 
    exit 1
  fi
}

# Check for the existence of rsync
check_for_rsync() {
  if [ ! hash rsync 2>/dev/null ]; then
    output_message "rsync command not found" 
    exit 2
  fi
}

# Execute the backup
execute_backup() {
  # Set some vars
  local config_file="/etc/rainbowscripts/backupnas.conf"
  local include_file="/etc/rainbowscripts/backupnas-include.txt"

  # Read vars from the config file
  if [ -f ${config_file} ]; then
    . ${config_file}
  else
    output_message "${config_file} config file not found."
    exit 3
  fi

  # Check if all the required vars has a value
  if [ -z "${nas_address_and_path}" ]; then
    output_message "nas_address_and_path var not found. Please check config file at ${config_file}"
    exit 4
  fi

  # Check if the file with the files/folders to backup exists
  if [ ! -f ${include_file} ]; then
    output_message "${include_file} file not found."
    exit 5
  fi

  #rsync -arv --delete --progress -e "ssh" /home/homeassistant backup@192.168.100.2:/volume1/NetBackup/bck_homeassistant/home
  local result="$(rsync -arv --delete --progress -e \"ssh\" --files-from=${include_file} / ${nas_address_and_path} | grep sent )"
  output_message "Backup executed: ${result}"
}


check_for_root
check_for_rsync
execute_backup
