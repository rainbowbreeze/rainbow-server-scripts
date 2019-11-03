#!/bin/bash

# This script sends text to Yellow Butler service, asking to notify administrator
#
# Required files
# /etc/yellowbutler.conf
#  Store configurations for yellow butler call, like the API key and the address of the server
#
#
# Part of the RainbowScripts suite

variable_set() {
	local variable="${1}"
	local value="${2}"
	if [ -z "${!variable}" ]; then
		eval "${variable}=\"${value}\""
	fi
}

variables_set_defaults() {
	variable_set "config_file" "/etc/rainbowscripts.conf"
}


# Check for the presence of the config file
check_for_config_file() {
	local config_found=0

	if [ -f ${config_file} ]; then
  	. ${config_file}
		config_found=1
	fi

	# Workaroud for local execution of the script
	if [ -f conf/rainbowscripts.conf ]; then
		. conf/rainbowscripts.conf
		config_found=1
	fi

	if [ ${config_found} -eq 0 ]; then
		echo "Config file not found. Default file is ${config_file}"
		exit 1
	fi
}

check_for_required_vars () {
	if [ -z "${api_key}" ]; then
		echo "api_key not found. Please check config file at ${config_file}"
		exit 2
	fi

	if [ -z "${server_address}" ]; then
		echo "server_address not found. Please check config file at ${config_file}"
		exit 2
	fi

	if [ -z "${host_name}" ]; then
		echo "host_name not found. Please check config file at ${config_file}"
		exit 2
	fi

	if [ -z "${message}" ]; then
		echo "message not found. Please specify it as the first command line argument"
		exit 2
	fi
}


variables_set_defaults
check_for_config_file

# Check for the esistence of a command line argument
if [ -z "$1" ]; then
  # read from STDIN, and the text can be piped
  # echo "Message to send" | thisscript.sh

	# Read the first line
	read -r message
	# then read the others, attaching a \n only from the second ongoing
  while read -r line; do
		message="${message}\n${line}"
	done
else
  #read the first commmand line argument
  variable_set "message" "$1"
fi

check_for_required_vars

message="Message from host ${host_name}\n${message}"
curl -X POST ${server_address}/yellowbot/api/v1.0/intent -H "X-Authorization:${api_key}" -H "Content-Type: application/json" -d "{\"intent\":\"notify_admin\", \"params\":{\"message\":\"${message}\"}}"
