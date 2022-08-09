#!/bin/bash

reset=`tput sgr0`    # reset
green=`tput setaf 2` # green
red=`tput setaf 1`   # red

TOKEN=$1

if [ $(curl --user "$USER:$TOKEN" https://api.github.com/users/$USER 2>/dev/null|grep -o private_gists|xargs) == "private_gists" ] 2>/dev/null || [ $(curl --user "$USER:$TOKEN" https://api.github.com/users/$USER 2>/dev/null|grep -o private_gists|xargs) == "private_gists" ] 2>/dev/null
then
  echo ""
  echo "${green} $USER's git token has been successfully validated${reset}!"
  echo ""
else
  echo ""
  echo "${red} Script failed to validate $USER's git token${reset}!"
  echo ""
fi