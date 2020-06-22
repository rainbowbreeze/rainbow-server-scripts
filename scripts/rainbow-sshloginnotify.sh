#!/bin/bash

# This script is run by PAM when a new SSH login happens. It sends a
#  notification with some of the login info
#
# Inspired by
# - https://blog.tommyku.com/blog/send-telegram-notification-on-ssh-login/
#
# Remember to add the following line to /etc/pam.d/sshd
# session optional pam_exec.so /use/local/bin/rainbow-sshloginnotify.sh
#
# Part of the RainbowScripts suite


if [ ${PAM_TYPE} = "open_session" ]; then
  message="$PAM_USER@$PAM_RHOST: knock knock via $PAM_SERVICE"
  rainbow-notifyadmin.sh ${message} > /dev/null 2>&1
fi
