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
git_repo="https://github.com/rainbowbreeze/rainbow-server-scripts.git/"
# Current version of the scripts installed on this host
# current_version="/var/log/rainbow-script-version.txt"

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

# Update RainbowScripts
download_repo_and_lauch_update() {
  # Creates the temp directort
  local tmp_dir=$(mktemp -d -t ci-$(date +%Y-%m-%d-%H-%M-%S)-XXXXXXXXXX)
  
  # First, create the folder with all the scripts
  output_message "Downloading RainbowScripts..."
  local script_dir="${tmp_dir}/repo"
  git clone -quite ${git_repo} ${script_dir} >/dev/null 2>&1
  
  # Check if the download failed
  # TODO more robust check, based on the output of git
  if [ ! -d ${script_dir} ]; then
    output_message "Error while cloning git repo at ${git_repo}. Update aborted."
    exit 1
  fi

  # Launch the update
  local script
  ${script_dir}/scripts/updater-core.sh ${script_dir}

  # Removing temp dir
  rm -rf "${tmp_dir}"
}


# Check if the command was launched using root permissions
check_for_root
download_repo_and_lauch_update
