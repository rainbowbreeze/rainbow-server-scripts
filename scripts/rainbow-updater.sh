#!/bin/bash

# This scrips updates all the Rainbow scripts in the system
# - Clone the Rainbowscripts repository
# - Delete potentially old files
# - Copy new files in the appropriate directories
#
#
# Part of the RainbowScripts suite


# TOOD
# Check for missing packages: https://github.com/billw2/rpi-clone/blob/master/rpi-clone

# Common vars
git_repo="https://github.com/rainbowbreeze/rainbowscripts.git/"
# Current version of the scripts installed on this host
# current_version="/var/log/rainbow-script-version.txt"

# Check for root execution
check_for_root() {
  if [[ $EUID -ne 0 ]]; then
    output_message "This script must be run as root" 
    exit 1
  fi
}

# Show a message
output_message() {
  echo "${1}"
}

# Copy a file to a particular location
# Param 1 is the file name
# Param 2 is the destination
copy_file() {
  #echo " -> Copy ${source} to ${destination}"
  cp "${source}" "${destination}"
}

# Copy a file to a particular location and set executable flag
# Param 1 is the file name
# Param 2 is the destination
copy_exec_file() {
	local source="${1}"
	local destination="${2}"

  chmod +x ${source}
  copy_file ${source} ${destination}
}

# Copy a file to a particular location and set executable flag
# Param 1 is the file name
# Param 2 is the destination
copy_config_file() {
	local source="${1}"
	local destination="${2}"

  chmod 640 ${source}
  copy_file ${source} ${destination}
}

# Update RainbowScripts
update_scripts() {
  # Creates the temp directort
  local tmp_dir=$(mktemp -d -t ci-$(date +%Y-%m-%d-%H-%M-%S)-XXXXXXXXXX)
  
  # First, create the folder with all the scripts
  output_message "Downloading RainbowScripts..."
  cd ${tmp_dir}
  local script_dir="repo"
  git clone -quite ${git_repo} ${script_dir} >/dev/null 2>&1
  
  # Check if the download failed
  # TODO more robust check, based on the output of git
  if [ ! -d ${script_dir} ]; then
    output_message "Error while cloning git repo at ${git_repo}. Update aborted."
    exit 1
  fi

  # Copy the files where they need to be copied
  output_message "Installing RainbowScripts on this system"
  cd ${script_dir}
  # Copy scripts
  copy_exec_file "scripts/rainbow-notifyadmin.sh" "/usr/local/bin/"
  copy_exec_file "scripts/rainbow-updater.sh" "/usr/local/bin/"
  copy_exec_file "scripts/rainbow-upgradesystem.sh" "/usr/local/bin/"
  copy_exec_file "scripts/rainbow-backupnas.sh" "/usr/local/bin/"

  # Copy cron jobs
  copy_exec_file "scripts/cron/rainbow-cron-packages" "/etc/cron.daily/"
  copy_exec_file "scripts/cron/rainbow-cron-updater" "/etc/cron.daily/"
  copy_file "scripts/cron/rainbow-cron-backupnas" "/etc/cron.d"
  chmod 640 "/etc/cron.d/rainbow-cron-backupnas"  # Maybe it's not really necessary, altought https://unix.stackexchange.com/a/296351

  # Create the config folder, if necessary
  local config_folder="/etc/rainbowscripts"
  if [ ! -d "${config_folder}" ]; then
    output_message "Creating config folder"
    mkdir "${config_folder}"
  fi

  # Copy configuration for notify script if config file doesn't exist
  for config_source_file in "notifyadmin.conf" "backupnas.conf" "backupnas-include.conf"
  do
    local config_dest_file="${config_folder}/${config_source_file}"
    if [ ! -f ${config_dest_file} ]; then
      copy_config_file "scripts/conf/${config_source_file}" "${config_dest_file}"
      output_message " --> Before running the scripts, please edit config on ${config_dest_file}, adding your values <--" 
    fi
  done

  # Removing temp dir
  cd
  rm -rf "${tmp_dir}"

  output_message "RainbowScripts updated to the latest version"
}


# Check if the command was launched using root permissions
check_for_root
update_scripts
