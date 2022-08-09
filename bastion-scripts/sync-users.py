from github import Github
import os, json, logging, sys, pwd, grp, time
import argparse

logging.basicConfig()
logging.getLogger().setLevel(logging.INFO)

organization_name = "fuchicorp"
g = Github(os.environ.get("GIT_TOKEN"))
organization = g.get_organization(organization_name)


## Teams which will have access to bastion host 
root_access_teams = ['admin']
non_root_access_teams = ['pro', 'basic', 'premium', 'contributors']
mentors = ['mentors', 'admin']
mentor_keys = []

parser = argparse.ArgumentParser()
parser.add_argument('-t', '--teams', type = str, nargs='*') # updates specified teams with mentors, if flag not invoked updates all
parser.add_argument('-r', '--refresh', action='store_true') # refreshes tags/comments/name (the user['comments'] section) of the users
parser.add_argument('-f', '--ssh_file', default=argparse.SUPPRESS, type=str, nargs='?') # refreshes appropriate users ssh keys, from defualt local ssh mentor file, or specify name of ssh file 
parser.add_argument('-u', '--update_ssh', default=argparse.SUPPRESS, type=str, nargs='?') # updates mentors, and local mentors ssh file, specify name of the ssh file otherwise set to default
args = parser.parse_args()

refresh_flag = ""
default_ssh_file = "ssh_mentor_keys"

## Empty data which will store output
github_organization_users = {
    "data"              : [],
    "non_root_access"   : [],
    "all_uniq_users"    : []
}

    ## Iterating list of user
def templetize_user_data(team_name):
    team_object = organization.get_team_by_slug(team_name)
    logging.info(f"####### Getting all members from team <{team_object.name}>")
    member_items = organization.get_team(team_object.id).get_members()
    for user in member_items:
        
        ## if the user has ssh keys
        if user.get_keys().totalCount:

            ## templetizing the user data
            user_data = {
                "username"  : user.login, 
                "ssh-keys"  : [],
                "comment"   : f"<{user.name}>, <{user.email}>, <{user.company}>, <{team_name}> <fuchicorp-scripts>",
                "is_root"   : False
            }

            ## Checking file exists if yes then delete
            if os.path.isfile(f'{user_data["username"]}.key'):
                os.remove(f'{user_data["username"]}.key')

            ## Iterating list of users keys
            key_items = user.get_keys()

            for key in key_items:
                user_data['ssh-keys'].append(key.key)

            if team_name in non_root_access_teams:
                user_data['ssh-keys'].extend(mentor_keys)

            ## add only mentors ssh keys
            if team_name in mentors: 
                mentor_keys.extend(user_data['ssh-keys'])
            
            with open(f'{user_data["username"]}.key', 'a') as f:
                for val in user_data['ssh-keys']:
                    f.write("%s\n" % val)

            ## Making sure users are getting proper access 
            if team_name in root_access_teams: 
                user_data['is_root'] = True
                
            ## Get user from organization
            if user_data["username"] not in github_organization_users['all_uniq_users'] :
                github_organization_users['all_uniq_users'].append(user_data['username'])
                github_organization_users['data'].append(user_data)
        else:
            logging.warning(f"User <{user.login}> does not have ssh key uploaded on github.")

if not os.geteuid() == 0:
    sys.exit("\nOnly root can run this script\n")

if "update_ssh" in args:
    for mentor in mentors:
        github_organization_users['data'].append(templetize_user_data(mentor))
    if args.update_ssh == None:
        with open(default_ssh_file, 'w') as f:
            for val in mentor_keys:
                f.write("%s\n" % val)
    else:
        with open(args.ssh_file, "w") as f:
            for val in mentors:
                f.write("%s\n" % val)
    exit()


if args.teams:
    if "ssh_file" in args:
        if args.ssh_file == None:
            with open(default_ssh_file, "r") as f:
                mentor_keys.extend(f.read().splitlines())
        else:
            with open(args.ssh_file, "r") as f:
                mentor_keys.extend(f.read().splitlines())
    else:
        for mentor in mentors:
            github_organization_users['data'].append(templetize_user_data(mentor))
    for team in args.teams:
        github_organization_users['data'].append(templetize_user_data(team))
        
else:
    for mentor in mentors:
        github_organization_users['data'].append(templetize_user_data(mentor))
    ## Templetizing root members 
    for root_team in root_access_teams:
        github_organization_users['data'].append(templetize_user_data(root_team))
    ## Templetizing none root members 
    for non_root_team in non_root_access_teams:
        github_organization_users['data'].append(templetize_user_data(non_root_team))


## Creating all users 
if args.refresh:
    refresh_flag = "--refresh"

for user in github_organization_users['data']:
    if user is not None:
        if user['is_root']:
            # print(f"""###### {user["username"]} '{user["comment"]}' {user["username"]}.key --admin""")
            time.sleep(5)
            ## Added sleep based on the worksession 
            ## https://github.com/fuchicorp/bastion/issues/12
            os.system(f"""sudo sh sync-all-bastion-users.sh {user["username"]} '{user["comment"]}' {user["username"]}.key --admin {refresh_flag}""")
        else:
            # print(f"""###### {user["username"]} '{user["comment"]}' {user["username"]}.key """)
            os.system(f"""sudo sh sync-all-bastion-users.sh {user["username"]} '{user["comment"]}' {user["username"]}.key {refresh_flag}""")

## Disabling users if user is not in the organization
for bastion_user in pwd.getpwall():

    ## If users has comment <fuchicorp-scripts>
    # use [-1] easier when appending values, fixed 
    if '<fuchicorp-scripts>'in bastion_user[-1]:

        ## If users username is not in the organization 
        if bastion_user[0] not in github_organization_users['all_uniq_users']:

            ## Disabling bastion host accesss also deleting from wheel group 
            output = os.system('sudo gpasswd -d ' + bastion_user[0] + '  wheel 2>/dev/null ')
            output = os.system('sudo usermod ' + bastion_user[0] + ' -s /sbin/nologin 2> /dev/null') 
            logging.warning(f'User <{bastion_user[0]}> was disabled from bastion host and deleted from wheel group.')

        ## If user in the system and user in the organization 
        if bastion_user[0] in github_organization_users['all_uniq_users']:
            output = os.system('sudo usermod ' + bastion_user[0] + ' -s /bin/zsh 2> /dev/null')

## Saving output for debuging 
with open("output.json", "w") as file:
    json.dump(github_organization_users, file, indent=2)
