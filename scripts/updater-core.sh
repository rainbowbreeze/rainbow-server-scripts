#!/bin/bash

# This scrips updates all the Rainbow scripts in the system
# - Delete potentially old files
# - Copy new files in the appropriate directories
#
# It works on the assumption that someone has already downloaded the git repo
#  with all the updated files
#
#
# Part of the RainbowScripts suite

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

# Copy a file to a particular location and change its permissions
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
  # Get the script path
  local script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
  #Get the parent folder
  local script_dir="$(dirname "${script_dir}")"

  # Copy the files where they need to be copied
  output_message "Installing RainbowScripts..."
  cd ${script_dir}
  # Copy scripts
  # /usr/local/bin is for normal user programs not managed by the distribution package manager, e.g. locally compiled packages
  # /usr/local/sbin is for system management programs (not normally used by ordinary users)
  local bin_dir="/usr/local/bin/"
  copy_exec_file "scripts/rainbow-notifyadmin.sh" "${bin_dir}"
  copy_exec_file "scripts/rainbow-updater.sh" "${bin_dir}"
  copy_exec_file "scripts/rainbow-upgradesystem.sh" "${bin_dir}"
  copy_exec_file "scripts/rainbow-backupnas.sh" "${bin_dir}"
  copy_exec_file "scripts/rainbow-sshloginnotify.sh" "${bin_dir}"

  # Copy daily cron jobs
  local cron_daily_dir="/etc/cron.daily/"
  copy_exec_file "scripts/cron/rainbow-cron-packages" "${cron_daily_dir}"
  copy_exec_file "scripts/cron/rainbow-cron-updater" "${cron_daily_dir}"

  # Copy time-specific cron jobs
  local cron_d_dir="/etc/cron.d/"
  # Maybe it's not really necessary, altought https://unix.stackexchange.com/a/296351
  copy_config_file "scripts/cron/rainbow-cron-backupnas" "${cron_d_dir}"

  # Create the config folder, if necessary
  local config_folder="/etc/rainbowscripts"
  if [ ! -d "${config_folder}" ]; then
    output_message "Creating config folder"
    mkdir "${config_folder}"
  fi

  # Copy configuration files if they don't already exist
  for config_source_file in "notifyadmin.conf" "backupnas.conf" "backupnas-include.conf"
  do
    local config_dest_file="${config_folder}/${config_source_file}"
    if [ ! -f ${config_dest_file} ]; then
      copy_config_file "scripts/conf/${config_source_file}" "${config_dest_file}"
      output_message " --> Before running the scripts, please edit config on ${config_dest_file}, adding your values <--" 
    fi
  done

  cd - > /dev/null 2>&1
  output_message "RainbowScripts updated to the latest version"
}

# Check if the command was launched using root permissions
check_for_root
update_scripts

