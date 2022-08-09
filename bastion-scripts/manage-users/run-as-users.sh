#!/bin/bash 

USERS="$(cat /etc/passwd | grep -i 'fuchicorp-scripts' | grep 'bin/bash' | awk -F ':' '{print $1}')"

for user in $USERS; do
    # sudo runuser -l "$user" -c "$1"
    echo "Running the script as $user"
    sudo su "$user" $1
    echo "The script it finished for $user"
done
