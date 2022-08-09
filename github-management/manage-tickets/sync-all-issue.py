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
repo_milestones = [ milestone.title for milestone in repo.get_milestones()]
for milestone in data['tickets']:
    if milestone['milestone'] not in repo_milestones:
        repo.create_milestone(title=milestone['milestone'])
        print(f"INFO: Created <{milestone['milestone']}> milestone in the repo!")
    


for user in github_members:
    ## Getting user ticket in the github to avoid dublicates
    github_user_tickets = []
    for issue in repo.get_issues(assignee=user.login, state='all'):
        for local_issue in data['tickets']: 
            if local_issue['title'] in issue.title:
                github_user_tickets.append(issue.title)

    ## If any issues are missing for the github user it will create one
    for issue in data['tickets']:
        if issue['title'] not in github_user_tickets:
            for milestone in repo.get_milestones():
                if milestone.title == issue['milestone']:
                    ## Getting all labels from the org
                    founded_label_clases    = []
                    for local_label in issue['labels']:
                        try:
                            founded_label_clases.append(repo.get_label(local_label))
                        except:
                            sys.exit(f"ERROR: The label not found <{local_label}> please contact admin to create one!")

                    repo.create_issue(title=f"{issue['title']}",  body=issue['body'],  assignee=user.login, milestone=milestone, labels=founded_label_clases )
                    print(f"Created <{issue['title']}> ticket for <{user.login}>")
                    time.sleep(2)
        else:
            print(f"INFO: <{user.login}> has already ticket <{issue['title']}>")

        ## If the body was updated in data.yaml this for loop should update it
        for github_issue in repo.get_issues(assignee=user.login):
            if github_issue.title == issue['title'] and github_issue.body != issue['body']:
                github_issue.edit(body=issue['body'])
                print(f"INFO: Found udpate for <{user.login}> ticket {github_issue.title}")

# user = g.get_user('fsadykov')
# for item in repo.get_issues(assignee='fsadykov', state='all'):
#     print(item.state)
