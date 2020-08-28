#!/bin/bash

# This scrips performs a backup to a rsync server
#
# TODO
# - Add a command-line paramenter to introduce a random delay
#
#
# Part of the RainbowScripts suite


# Show a message
output_message() {
  echo ${1}
}

# Check for root execution
check_for_root() {
  if [ $EUID -ne 0 ]; then
    output_message "This script must be run as root" 
    exit 1
  fi
}

# Check for the existence of rsync
check_for_rsync() {
  if ! hash rsync 2>/dev/null; then
    output_message "rsync command not found" 
    exit 2
  fi
}

# Execute the backup
execute_backup() {
  # Set some vars
  local config_file="/etc/rainbowscripts/backupnas.conf"
  local include_file="/etc/rainbowscripts/backupnas-include.conf"

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
  # Check if all the required vars has a value
  if [ -z "${nas_ssh_key_file}" ]; then
    output_message "nas_ssh_key_file var not found. Please check config file at ${config_file}"
    exit 4
  fi

  # Check if the file with the files/folders to backup exists
  if [ ! -f ${include_file} ]; then
    output_message "${include_file} file not found."
    exit 5
  fi

  # Check if the file with the files/folders to backup exists
  if [ ! -f ${nas_ssh_key_file} ]; then
    output_message "${nas_ssh_key_file} file not found."
    exit 6
  fi

  local rsync_out=$(mktemp)
  rsync -arv --delete -e "ssh -i ${nas_ssh_key_file}" --files-from=${include_file} / ${nas_address_and_path} > ${rsync_out} 2>&1
  local rsync_exit=$?
  local result_message=""
  if [ ${rsync_exit} -eq 0 ]; then
    local rsync_info=$(grep sent ${rsync_out})
    result_message="Backup executed: ${rsync_info}"
  else
    local rsync_err=$(grep rsync: ${rsync_out})
    result_message="Backup ended with error ${rsync_exit}: ${rsync_err}"
  fi
  output_message "${result_message}"
  # Full path is necessary, otherwise the comman cannot be found when launched as root in cronjob
  /usr/local/bin/rainbow-notifyadmin.sh "${result_message}"
  rm ${rsync_out}
}

check_for_root
check_for_rsync
execute_backup
