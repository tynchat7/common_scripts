import argparse
import os
from github import Github

## organization name and token on env
organization = 'fuchicorp'
token = os.environ.get("GIT_TOKEN")

if not os.environ.get('GITHUB_USERNAME'):
    print('Please create environment variable <GITHUB_USERNAME> with list of users')
    exit(1)

team_to_add = os.environ.get('MEMBERSHIP')
users = os.environ.get('GITHUB_USERNAME').splitlines()

## Getting github user and organization 
g = Github(token, base_url='https://api.github.com')
org = g.get_organization(organization)



parser = argparse.ArgumentParser(description='Script to manage Fuchicorp Github Organization. Please follow the option to delete or invite poeple')

parser.add_argument('--invite', const=True, default=False, nargs='?',
                    help='Inviting github users to FuchiCorp organization.')

parser.add_argument('--delete', const=True, default=False, nargs='?',
                    help='Deleting github users from FuchiCorp organization.')

parser.add_argument('--changeUserTeam', const=True, default=False, nargs='?',
                    help='Adding existing user to different FuchiCorp Organization Team.')
args = parser.parse_args()


## Function takes list and gettes users and returns as list 
def get_users(users):
    ## Empty list which will be returned 
    result = []
    for user in users:
        try:
            result.append(g.get_user(user))     ## Trying to get user and append to result
        except:
            print(f"User not found <{user}>")
    return result


if args.invite:
    ## Users class using script to be able to get github users 
    user_clases = get_users(users)
    teams = org.get_teams()     ## Getting all teams 
    for team in teams:          ## Lopping to each teams
        ## If team is part of members
        ## looping to users class to be able to onboard to memebers team 
        for user in user_clases:
            if team.name == team_to_add:
                try:
                    org.invite_user(user=user, teams=[team])    ## Trying to invite user to organization   
                    print(f"User <{user.login}> has been invited to join Fuchicorp <{team.name}>")
                    print("Please ask Members to accept the invitation from Fuchicorp on Github")
                except:
                    print(f"User <{user.login}> is already part of <{team.name}>")
        else: 
            print("The team can't be found in the organization") 


elif args.delete:
    for user in users:                     ## looping to users to delete 
        try:                               ## Trying to get the user 
            user = g.get_user(user)     
            org.remove_from_members(user)  ## Deleted user from organization
            print(f"User <{user}> has been successfully deleted from Fuchicorp on Github")

        except Exception as error:
            print(f"User <{user}> {error}")
            print(f"User <{user}> is not a member of Fuchicorp")


elif args.changeUserTeam:
    if os.environ.get('MEMBERSHIP'):    
        for user in users:              ## Check the user if user exist in the organization
            user = g.get_user(user)
            teams = org.get_teams()
            for team in teams:          ## Check the team from the organization
                ## Then change user membership in the organization
                if team.name != team_to_add and team.has_in_members(user):
                   team.remove_membership(user)
                if team.name == team_to_add:
                    team.add_membership(user)   
                    print(f"The {user.name} was added to the team {team.name}!!")
    else:
        print("Error: Missing environment variable <MEMBERSHIP>")