#!/bin/bash
### Script to clean up 1000 pods with error and pening to create
if timeout 5 kubectl get pod > /dev/null; then 
    # kubectl get pod -n tools | grep -i jenkins-pipeline | grep "Pending|Error" | awk '{print $1}' | head -n 1000
    PODS="$(kubectl get pod -n tools | grep -i jenkins-pipeline | grep -E "Pending|Error" | awk '{print $1}' | head -n 1000)"
    for pod in "$PODS"; do  
        kubectl delete pod -n tools $pod;
    done 
fi 