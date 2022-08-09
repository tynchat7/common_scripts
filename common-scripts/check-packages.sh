#!/bin/bash

declare -a ListOfPackages=("packer" "terraform" "kubectl" "docker-compose" "docker" "helm" "python3" "tree" "curl" "wget" "java" "groovy"  "waypoint" "nslookup") 
for val in ${ListOfPackages[@]}; do

    if $val -version &> /dev/null || $val --version &> /dev/null || $val version &> /dev/null; then 
        echo "$val is installed"
    else
        echo "$val is not installed"
    fi 
done

