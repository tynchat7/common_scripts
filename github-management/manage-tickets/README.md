# Create all tickets for basic members


By following	this documentation you should be able to create all get stared tickets 
```
cd ~/common_scripts/github-management/manage-tickets
```


First you will need to generate your token or use the existing one 
[Generate my github token ](https://github.com/settings/tokens) Note: The token should have access to create ticket in the repo 

The script is looking for GIT_TOKEN env  so make sure you export it 
```
export GIT_TOKEN='github-token'
```


You need to export the team name to create all required tickets 
```
 export GITHUB_TEAM_NAME='premium'
```


There is optional env to use custom repo name if you will skip this step the script will use `main` repo 
```
export GITHUB_REPO_NAME='basic'
```


To run the script you should execute following command 
```
python3 script.py     
```




Work session was uploaded here
https://academy.fuchicorp.com/videos/folders/watch/79295fc997e844691f26b0a6c70a593dc24fee22