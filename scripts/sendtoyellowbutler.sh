#!/bin/bash

# This script sends text to Yellow Butler service, asking to notify administrator
#
# Required files
# /etc/yellowbutler.conf
#  Store configurations for yellow butler call, like the API key and the address of the server
#
#
variables_reset() {
	# internal variables
	logfile=
	api_key=
	server_address=
}

variable_set() {
	local variable="${1}"
	local value="${2}"
	if [ -z "${!variable}" ]; then
		eval "${variable}=\"${value}\""
	fi
}

variables_set_defaults() {
	variable_set "config_file" "./yellowbutler.conf"
}


# Check for the presence of the config file
check_for_config_file() {
	if test -f ${config_file}; then
  	. ${config_file}
	else
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

echo "Message read:"
echo ${message}
echo "-----------"

check_for_required_vars

curl -X POST ${server_address}/yellowbot/api/v1.0/intent -H "X-Authorization:${api_key}" -H "Content-Type: application/json" -d "{\"intent\":\"notify_admin\", \"params\":{\"message\":\"${message}\"}}"
