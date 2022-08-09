from github import Github
import os, yaml, time, sys


organization = 'fuchicorp'
repo_name = 'main'
team_name = 'basic'
metadata_file = 'data.yaml'

with open(metadata_file) as yaml_file:
    data = yaml.load(yaml_file, Loader=yaml.FullLoader)

## Making sure that GIT_TOKEN provided from the user 
if os.environ.get('GIT_TOKEN'):
    token = os.environ.get('GIT_TOKEN')
else:
    sys.exit('ERROR: <GIT_TOKEN> not found from env!')

## Trying to get team name from user if not the script will use default
if os.environ.get('GITHUB_TEAM_NAME'):
    team_name = os.environ.get('GITHUB_TEAM_NAME')
else:
    print(f"INFO: Using default team to create tickets {team_name}")

## If the custom repo was mentioned 
if os.environ.get('GITHUB_REPO_NAME'):
    repo_name = os.environ.get('GITHUB_REPO_NAME')
else:
    print(f"INFO: Using default repo {repo_name}")



g = Github(token)
org = g.get_organization(organization)
repo = org.get_repo(repo_name)
try:
    github_team  = org.get_team_by_slug(team_name)
    github_members = github_team.get_members()
except:
    print("The team in the organization does not exist or the member isn't part of the team")


## Making sure all milestones are created
for milestone = repo.get_milestones():
    milestone


    