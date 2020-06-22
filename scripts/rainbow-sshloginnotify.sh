#!/bin/bash

# This script is run by PAM when a new SSH login happens. It sends a
#  notification with some of the login info
#
# Requires
# - jq package to be installed (sudo apt install jq)
#
# Inspired by
# - https://blog.tommyku.com/blog/send-telegram-notification-on-ssh-login/
# - https://8192.one/post/ssh_login_notification_withtelegram/
# - https://gitlab.com/snippets/1871482#note_188602535
#
# Remember to add the following line to /etc/pam.d/sshd
# session optional pam_exec.so /use/local/bin/rainbow-sshloginnotify.sh
# Setting the session to ‘optional’ will allow the user to login in case the
#  script fails. (ex. Telegram servers are down) This prevents you from being
#  locked out. But setting the session to ‘required’ will enforce the
#  execution of the script as absolute
#
# Part of the RainbowScripts suite


#if [ ${PAM_TYPE} = "open_session" ]; then
#  message="$PAM_SERVICE login at $PAM_USER@$PAM_RHOST"
#  rainbow-notifyadmin.sh "${message}" > /dev/null 2>&1
#fi

if [ ${PAM_TYPE} = "open_session" ]; then
  date_exec="$(date "+%d %b %Y %H:%M")" #Collect date & time.

  #Check what could be done querying ipinfo.io
  tmp_file="$(mktemp)" #Create a temporary file to keep data in. # True temporary file
  curl https://ipinfo.io/$PAM_RHOST -s -o $tmp_file #Get info on client IP.
  IP_INFOS="$(jq -r '.org + " - " + .city + ", " + .region + ", " + .country' "$tmp_file")" #Client IP info parsing via jq

  message="$PAM_USER@$PAM_RHOST login to $PAM_SERVICE at $date_exec - Other info: $IP_INFOS"
  rm $TMPFILE #clean up after

  rainbow-notifyadmin.sh "${message}" > /dev/null 2>&1
fi

