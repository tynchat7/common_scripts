import argparse
import os
from github import Github


environments = [
    'dev',
    'qa',
    'stage', 
    'prod'
]

## organization name and token on env
organization = 'fuchicorp'
token = os.environ.get("GIT_TOKEN")

g = Github(token, base_url='https://api.github.com')
org = g.get_organization(organization)

parser = argparse.ArgumentParser(description='Generate kubernetes config file for user.')
parser.add_argument('--username', help='Username to generate kube config')

## List all memebers of the team
args = parser.parse_args()
if args.username:
    user = args.username
    for environment in environments:
        team_name = f"{environment}-admin-team"
        github_team = org.get_team_by_slug(team_name)
        github_user = g.get_user(user)
        if github_team.has_in_members(github_user):
            print(f"I will be generating kube config!!! {environment}")
            os.system(f"bash set-kube-config.sh $(kubectl get endpoints  -o json | jq -r '.items[0].subsets[].addresses[].ip') {environment} {environment}-fuchicorp-service-account")
        else:
            print(f"User is not part of team {team_name}")
else:
    print("Username was not provided!!")
    exit(1)