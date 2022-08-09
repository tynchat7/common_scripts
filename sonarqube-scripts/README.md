## `sonarqube-snapshot.sh` is a bash script that will do the following:

* Backups from Sonarqube Postgresgl Database to sonarqube_home directory called `sonarqube_home` 
* Restores folders under `./sonarqube_home/backup.sql` directory back to sonarqube postgresgl when needed.


### Steps to take sonarqube snapshot(Preparation)

* Step 1
``` 
git clone https://github.com/fuchicorp/common_scripts.git
```
* Step 2
```
cd common_scripts/sonarqube-scripts 
```
* Step 3
Run the command: 
```
sh sonarqube-snapshot.sh --sync
```
- Creates sonarqube_home folder under current directory if it doesn't exist.
- It takes backup Postgresql Database  to sonarqube_home directory. 


## Restore
1. Run the command:

```
sh sonarqube-snapshot.sh --restore
```
- You will see the output: **Sonarqube Database Successfully restored**

2. You need to restart the Sonarqube with one of the 3 options:
```
type one of  3 option to agree:  "yes", "y", "Y" 
```
3. Wait for Sonarqube_pod to be in STATE “Running” 
4. You will se the output: **Sonarqube is restarted and ready to use!!!**


```



 To run the cronjob do `crontab -e` and add the following line  `0 0 * * FRI bash /common_scripts/sonarqube-scripts/sonarqube-snapshot.sh —-sync`. it will run every Friday at midnight to back up. 

 To be able to see the list of cronjob run `crontab -l`

