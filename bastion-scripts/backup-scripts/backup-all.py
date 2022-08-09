import os, json, requests, subprocess, pwd 
from pathlib import Path
from subprocess import PIPE
from alive_progress import alive_bar

"""
Author: Farkhod Sadykov
Email: sadykovfarkhod@gmail.com
Company: FuchiCorp LLC
All rights reserved 
"""


## base home directory
base_home       = '/fuchicorp/home'

## Backup folder for users
backup_folder   = '/fuchicorp/backups'

## select following comment on each exising users
user_select     = 'fuchicorp-scripts'

## Find following files and take backup
to_backup_list  = [
    'bastion.tfvars',
    'cluster.tfvars',
    'common_tools.tfvars',
    'google-credentials.json',
]

## Empty list of users
users = [
]


## Appending existing users from bashtion host
for user in pwd.getpwall():
    if f"{user_select}" in user[4]:
        users.append(user[0])


## Function to find files from the locations
def find_file(file, username):
    return list(
        str(
            subprocess.run(['sudo', 'find', f"{base_home}/{username}/", '-iname', f"{file}"], stdout=PIPE, stderr=PIPE).stdout
        ).replace("b'", "").replace("'", "").split('\\n')
    )[0:-1]

## Function to make sure files are stored in same folder
def create_same_folder(found_file, base_home, backup_folder):
    ## Making sure that base_home, backup_folder replaced
    to_backup_file_path = found_file.replace(base_home, backup_folder)
    ## Making sure that folder exist 
    base_dir_for_file = Path(os.path.dirname(to_backup_file_path))
    if not base_dir_for_file.is_dir():
        os.makedirs(os.path.dirname(to_backup_file_path))
        print(f"INFO: Created based folder: {os.path.dirname(to_backup_file_path)} for {to_backup_file_path}")
    return to_backup_file_path
    

## Function to copy a file to a path
def backup_file(file, to_path):
    return subprocess.run(['sudo', 'cp',  f"{file}", f"{to_path}"], stdout=PIPE, stderr=PIPE)

## Making sure that user gets proper progress
with alive_bar(len(users)) as progress_bar:

    ## Going over each users 
    for user in users:

        ## Creating the backup folder for the user 
        user_backup_home = Path(f"{backup_folder}/{user}/")
        if not user_backup_home.is_dir():
            print(f"INFO: Created backup folder for <{user}> path: <{backup_folder}/{user}/>" )
            os.makedirs(f"{backup_folder}/{user}/")

        ## Using the to_backup_list to take the backups
        for file_to_find in to_backup_list:
            for found_file in find_file(file_to_find, user):
            
                ## Making sure same folder is created
                backup_to_same_folder = create_same_folder(found_file, base_home, backup_folder)

                ## Making sure founded script will be stored in the same folder
                if backup_file(found_file, backup_to_same_folder).returncode == 0:
                    print(f"INFO: Copied <{found_file}> to {backup_folder}/{user}/")

        progress_bar()

