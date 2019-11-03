#!/bin/bash

# This scrips update all the Rainbow scripts in the system and reinstall them
#  in the appropriate directories
#
#
# Part of the RainbowScripts suite


# Common vars
# Current version of the scripts installed on this host
# current_version="/var/log/rainbow-script-version.txt"

update_scripts() {
  # Creates the temp directort
  #local tmp_dir=$(mktemp -d -t ci-$(date +%Y-%m-%d-%H-%M-%S)-XXXXXXXXXX)
  
  # First, update the folder with all the scripts
  # TODO - move to a root folder
  git pull
  # TODO check for the git output and, if this file was updates, relauch it

  # Then, copy the files where they need to be copied

  echo "Copying files across the system"
  # Copy scripts
  copy_file "scripts/rainbow-notifyadmin.sh" "/usr/local/bin/"
  #copy_file "scripts/rainbow-updater.sh" "/usr/local/bin/"

  # Copy cron jobs
  #copy_file "cron/rainbow-checkpackages" "/etc/cron.daily/"
  #copy_file "cron/rainbow-updatescripts /etc/cron.daily/"

  # Copy configurations
  # TODO revert command
  if [ ! -f /etc/rainbowscripts.conf ]; then
    copy_file "scripts/conf/rainbowscripts.conf" "/etc/"
  fi

  echo "RainbowScripts updateds to the latest version"

  # Copy current version
  # TODO
  #cp rainbow-script-version.txt ${current_version}
}


# Copy a file to a particular location
# Param 1 is the file name
# Param 2 is the destination
copy_file() {
	local filename="${1}"
	local destination="${2}"

  cp ${filename} ${destination}
}

# Copy a file to a particular location and set executable flag
# Param 1 is the file name
# Param 2 is the destination
copy_file_and_set_exec() {
	local filename="${1}"
	local destination="${2}"

  chmod +x ${filename}
  copy_file ${filename} ${destination}
}

# Check for root execution
check_for_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 
    exit 1
  fi
}

# Check if the command was launched using root permissions
check_for_root

update_scripts
exit

# Check if an update of the packages is required
if [ -z ${current_version} ]; then
  # File doesn't exists, install all the scripts
  update_scripts
fi

