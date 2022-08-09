#!/bin/bash

## Color codes
green=$(tput setaf 2)
red=$(tput setaf 1)
reset=$(tput sgr0)

## If JENKINS_HOME environment variable exist will take backup to that location
if [[ -z "${JENKINS_HOME}" ]]; then
  JENKINS_HOME='./jenkins_home'
  echo "Taking backup to default folder ${JENKINS_HOME}"
else
  echo "Found environment variable ${green}<JENKINS_HOME>${reset} taking backup to <${JENKINS_HOME}>"
fi

## If ~/.kube/config file doesn't exist. Create ~/.kube/config file
if [ ! -f ~/.kube/config ]; then
  echo ${red}"It turns out you don't have kubectl configured" $reset
  exit 1
fi


## If kubectl get nodes fails the script will fail
if ! kubectl get pod -n tools > /dev/null; then 
  echo ${red}'The script was not able to access to the cluster!!' $reset
  exit 1 
fi


## Creates jenkins_home folder under current directory if it doesn't exist.
if [ ! -d "$JENKINS_HOME" ]; then
  mkdir -p "$JENKINS_HOME"
  echo "${green}<$JENKINS_HOME)> directory is created${reset}"
fi



## Getting Jenkins pod name
JENKINS_POD_NAME="$(kubectl get pods -n tools | grep jenkins-tools | awk '{print $1}')"


function jenkins_restart_or_not() {
  read -p ""${green}"Should I ${red}restart "${green}"the Jenkins? [Y/n]:${reset} " yes

  ## give 3 option to agree "yes", "y", "Y"
  if [[ $yes == yes ]] || [[ $yes == y ]] || [[ $yes == Y ]];
  then

    kubectl delete pod "$JENKINS_POD_NAME" -n tools

    if [ $? != 0 ]; then
      echo ${red}'It was something wrong with restarting the Jenkins server' $reset
    fi 

    ## set Variable for new Jenkins_pod
    JENKINS_POD_NAME="$(kubectl get pods -n tools | grep jenkins-tools | awk '{print $1}' )"

    ## wait for Jenkins_pod to be in STATE "Running"    
    until [ "$(kubectl get pod  $JENKINS_POD_NAME -n tools | awk '{print $2}' | grep 2/2)" ]
    do
      echo "Jenkins pod is restarting ..." && sleep 10
    done

    if [ "$(kubectl get pod  $JENKINS_POD_NAME -n tools | awk '{print $2}' | grep 2/2)" ];
    then 
      echo "${green}Jenkins is restarted and ready to use!!!${reset}"
    fi

  elif  [[ $yes == no ]] || [[ $yes == n ]] || [[ $yes == N ]]; then  
    echo "Skipping deleting Jenkins."

  else
    echo "Misspelling, but anyway skipping deleting Jenkins"
  fi
}



## Sync the Jenkins home directory 
if [ "$1" = "--sync" ]; then
   ./krsync.sh -arv --progress --stats $JENKINS_POD_NAME@tools:/var/jenkins_home/secrets "$JENKINS_HOME" 
  echo "${green}Successfully copied secrets from jenkins server to jenkins_home <($JENKINS_HOME)> directory!${reset}"  

  ./krsync.sh -arv --progress --stats $JENKINS_POD_NAME@tools:/var/jenkins_home/secret.key "$JENKINS_HOME" 
  echo "${green}Successfully copied  secret.key from jenkins server to jenkins_home <($JENKINS_HOME)> directory!${reset}"

  ./krsync.sh -arv --progress --stats $JENKINS_POD_NAME@tools:/var/jenkins_home/jobs "$JENKINS_HOME" 
  echo "${green}Successfully copied jobs from jenkins server to jenkins_home <($JENKINS_HOME)> directory!${reset}"

  ./krsync.sh -arv --progress --stats $JENKINS_POD_NAME@tools:/var/jenkins_home/credentials.xml "$JENKINS_HOME"  
  echo "${green}Successfully copied credentials.xml from jenkins server to jenkins_home <($JENKINS_HOME)> directory!${reset}"

  ./krsync.sh -arv --progress --stats $JENKINS_POD_NAME@tools:/var/jenkins_home/config.xml "$JENKINS_HOME"  
  echo "${green}Successfully copied config.xml from jenkins server to jenkins_home <($JENKINS_HOME)> directory!${reset}"

  echo "${green}Successfully copied necessary folders from jenkins server to jenkins_home <($JENKINS_HOME)> directory!${reset}" 
fi




## Copies folders under ./jenkins_home directory back to jenkins server
if [ "$1" = "--restore" ]; then
  ./krsync.sh  -arv --progress --stats "$JENKINS_HOME/secrets" $JENKINS_POD_NAME@tools:/var/jenkins_home/ 
  echo "${green}Successfully copied secrets from jenkins server to jenkins_home <($JENKINS_POD_NAME)> directory!${reset}"

  ./krsync.sh  -arv --progress --stats "$JENKINS_HOME/secret.key" $JENKINS_POD_NAME@tools:/var/jenkins_home/ 
  echo "${green}Successfully copied secret.key from jenkins server to jenkins_home <($JENKINS_POD_NAME)> directory!${reset}"

  ./krsync.sh  -arv --progress --stats "$JENKINS_HOME/jobs" $JENKINS_POD_NAME@tools:/var/jenkins_home/ 
  echo "${green}Successfully copied jobs from jenkins server to jenkins_home <($JENKINS_POD_NAME)> directory!${reset}"

  ./krsync.sh  -arv --progress --stats "$JENKINS_HOME/credentials.xml" $JENKINS_POD_NAME@tools:/var/jenkins_home/
  echo "${green}Successfully copied credentials.xml  from jenkins server to jenkins_home <($JENKINS_POD_NAME)> directory!${reset}"

  ./krsync.sh  -arv --progress --stats "$JENKINS_HOME/config.xml" $JENKINS_POD_NAME@tools:/var/jenkins_home/
  echo "${green}Successfully copied config.xml  from jenkins server to jenkins_home <($JENKINS_POD_NAME)> directory!${reset}"

  echo "${green}Successfully copied necessary folders and files from jenkins server to jenkins_home <($JENKINS_HOME)> directory!${reset}"

  jenkins_restart_or_not
fi
