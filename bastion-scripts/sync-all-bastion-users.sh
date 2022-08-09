#!/usr/bin/env bash
# Color codes & helper functions
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
white=$(tput setaf 7)
reset=$(tput sgr0)
debug=1

USER_HOME='/fuchicorp/home'
admin_flag=0

## if you would like to enable a DebugMode change debug=1
debugMode () {
  if [ "$debug" -eq 1 ]; then
    echo "$1"
  fi
}


## Making sure you provide more then 3 arguments 
if [ "$#" -lt 3 ]; then
  debugMode "${red}More arguments required.${reset}"
  debugMode -e "$0 username \"Person's Name <email@example.com\" \"ssh-key\" [--admin]"
  exit 1
fi

## Making sure that script is runned as a root privilleges
if [[ $EUID -ne 0 ]]; then
  debugMode "This script must be run as root"
  exit 1
fi

## if debug mode On printing some outputs
debugMode "${yellow}Username:${reset} $1"
debugMode "${yellow}Name and Email:${reset} $2"
debugMode "${yellow}SSH PublicKey file:${reset} $3"


## If the folder home/user does not exist, user will be created
useradd "$1" -d "$USER_HOME/$1" --comment "$2" --shell /bin/zsh
chown "$1." -R "$USER_HOME/$1"

## check all arguments provided
for arg in "$@"
do
  case "$arg" in 
  ## if the script is running for users with admin privilleges
  --admin)
    echo "${yellow}Setting Admin privileges.${reset}"
    admin_flag=1
    usermod -aG wheel "$1"
    sed 's/# %wheel/%wheel/g' -i /etc/sudoers
  ;;
  ## if --refresh tag is invoked, update
  '-r' | '--refresh')
    usermod "$1" -c "$2" --shell  /bin/zsh 2> /dev/null
  ;;
  esac
done

if (("$admin_flag" == 0));then
  echo "${red}Removing Admin privileges.${reset}"
  gpasswd -d  "$1"  wheel 2> /dev/null
fi

## if the folder SSH does not exist for the user, it will be created and copied for the user
if [ ! -d "$USER_HOME/$1/.ssh" ]; then
  mkdir -p "$USER_HOME/$1/.ssh"
  debugMode "${green}Creating user's SSH directory.${reset}"
else
  debugMode "${yellow}User's ssh folder already exist.${reset}"
fi


## printing some outputs on debugMode and configuring SSH for the user
debugMode "${yellow}Updating the authorized_keys file${reset}"
cat "$3" > "$USER_HOME/$1/.ssh/authorized_keys"
debugMode "${yellow}Setting permissions.${reset}"

## Making sure users can not see each others files
chmod 750 "$USER_HOME/$1"

## Making sure user can login with ssh 
chmod 700 "$USER_HOME/$1/.ssh"
chmod 600 "$USER_HOME/$1/.ssh/authorized_keys"
chown -R "$1":"$1" "$USER_HOME/$1/.ssh"



## If user doesn't have ssh keys it will create for user 
if [ ! -f "$USER_HOME/$1/.ssh/id_rsa" ]; then
  su - $1 -c "ssh-keygen -t rsa -f $USER_HOME/$1/.ssh/id_rsa -q -N '' "
fi 
echo "${green}Created user (${yellow}$1${green}) for $2.${reset}"


## Adding users to docker group (to have execute permission on  /var/run/docker.sock) 
sudo usermod -aG docker $1