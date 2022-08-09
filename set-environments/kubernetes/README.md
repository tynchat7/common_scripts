# How to get kube config?  
#fuchicorp/common_scripts
Please follow this documentation to be able to generate your `~/.kube/config`. This script will create two service accounts one with admin access second just view access also after script is done it will create two files in your current directory 

## Before you begin
1. Make sure you can run `kubectl get sa --all-namespaces`
2. Make sure you have common tools deployed [LINK](https://github.com/fuchicorp/common_tools)

## Generate kube config
next you will need to clone the repo and get into script folder
```
git clone git@github.com:fuchicorp/common_scripts.git ~/common_scripts
cd ~/common_scripts/set-environments/kubernetes/
```


After you get into script folder you will need to check endpoint of the [kubernetes API](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/#:~:text=The%20Kubernetes%20API%20server%20validates,which%20all%20other%20components%20interact)
```
kubectl get endpoints ## This command should give API endpoints IP 
```


Let's confirm that service account are existing by running following command
```
kubectl get sa -n kube-system common-view common-admin 
```


Next step will be running the script to create service accounts and generate kube-config. If you see any problems with this command make sure you have access to cluster
```
bash set-kube-config.sh $(kubectl get endpoints | grep -v 'NAME' | awk '{print $2}')
```


If you will check your current directory you will see two files created
```
ls *config
admin_config view_config
```

You can go ahead and use one of the files to get access to your cluster cluster  