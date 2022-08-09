#!/bin/bash

###############################  sh sonarqube-snapshot.sh --sync ####################################
## Color codes
green=$(tput setaf 2)
red=$(tput setaf 1)
reset=$(tput sgr0)

## Getting sonarqube Postgresqlpod name
SONAR_DB="$(kubectl get pods -n tools | grep sonarqube-tools-postgresql | awk '{print $1}')"
#  Backup from Sonarqube Postgresgl Database to sonarqube_home directory under ./
SONAR_HOME='./sonarqube_home'

if [ "$1" == "--sync" ]; then
   ## If SONAR_HOME environment variable exist will take backup to that location
    if [[ -z "${SONAR_HOME}" ]]; then
      echo "Taking backup to default folder ${SONAR_HOME}"
    else
      echo "Found environment variable <sonarqube_home> taking backup to <${SONAR_HOME}>"
    fi


    ## Creates sonarqube_home folder under current directory if it doesn't exist.
    if [ ! -d "${SONAR_HOME}" ]; then
      mkdir -p "${SONAR_HOME}"

      echo "${green}<${SONAR_HOME})> directory is created${reset}"
    fi

kubectl exec -n tools $SONAR_DB -- bash -c "export PGPASSWORD='sonarPass' && pg_dump -c -h sonarqube-tools-postgresql  -U sonarUser sonarDB" > ${SONAR_HOME}/backup.sql
  echo "${green}Postgresql Database Successfully backed up  to sonarqube_home <(${SONAR_HOME})> directory!${reset}" 
fi


## Copies folders under ./sonarqube_home directory back to sonarqube postgresgl
#################################### sh sonarqube-snapshot.sh --restore" ###############################
if [ "$1" == "--restore" ]; then
  echo "${green} Restoring Sonarqube Database in progress${reset}"
  kubectl exec -i -n tools $SONAR_DB -- bash -c "export PGPASSWORD='sonarPass' && psql -h sonarqube-tools-postgresql -U sonarUser -d sonarDB" < ${SONAR_HOME}/backup.sql > /dev/null

  echo "${green} Sonarqube Database Successfully restored from <(${SONAR_HOME})> directory back to sonarqube postgresgl!${reset}"

      ## Output - ask to restart sonarqube_pod
  read -p ""${green}"Should I ${red}restart "${green}"the Sonarqube ? [Y/n]:${reset} " yes

         ## give 3 option to agree "yes", "y", "Y"
         ## set Variable for new sonarqube_pod
         SONAR_WEB="$(kubectl get pods -n tools | grep sonarqube-tools-sonarqube | awk '{print $1}' )"
        
      if [[ $yes == yes ]] || [[ $yes == y ]] || [[ $yes == Y ]];
      then
          kubectl delete pod "$SONAR_WEB" -n tools
                 ## set Variable for new Sonarqube_pod
          SONAR_WEB="$(kubectl get pods -n tools | grep sonarqube-tools-sonarqube | awk '{print $1}' )"
    
               ## wait for Sonarqube_pod to be in STATE "Running"    
            until [ "$(kubectl get pod  $SONAR_WEB -n tools | awk '{print $2}' | grep 1/1)" ]
            do
                echo "Sonarqube pod is restarting ..." && sleep 10
            done
                      if [ "$(kubectl get pod  $SONAR_WEB -n tools | awk '{print $2}' | grep 1/1)" ];
                      then 
                              echo "${green}Sonarqube is restarted and ready to use!!!${reset}"
                      fi
      elif  [[ $yes == no ]] || [[ $yes == n ]] || [[ $yes == N ]];
      then  
          echo "Skipping deleting Sonarqube."
      else
          echo "Misspelling, but anyway skipping deleting Sonarqube"
      fi
fi
