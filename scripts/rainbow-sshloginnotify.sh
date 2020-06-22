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

rainbow-notifyadmin.sh "Event type: ${PAM_TYPE}" > /dev/null 2>&1

if [ -n "$SSH_CLIENT" ] && [ -z "$TMUX" ]; then #Trigger
  date_exec="$(date "+%d %b %Y %H:%M")" #Collect date & time.
  tmp_file="$(mktemp)" #Create a temporary file to keep data in. # True temporary file
  IP=$(echo $SSH_CLIENT | awk '{print $1}') #Get Client IP address.
  PORT=$(echo $SSH_CLIENT | awk '{print $3}') #Get SSH port
  curl https://ipinfo.io/$IP -s -o $TMPFILE #Get info on client IP.
  IP_INFOS="$(jq -r '.org + " - " + .city + ", " + .region + ", " + .country' "$tmp_file")" #Client IP info parsing via jq
  TEXT="$date_exec: ${USER} logged in from $IP - ${IP_INFOS} port $PORT"

  rainbow-notifyadmin.sh "${TEXT}" > /dev/null 2>&1
fi
rm $TMPFILE #clean up after



