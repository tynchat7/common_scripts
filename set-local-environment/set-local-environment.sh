#!/bin/bash
DEBUG='False'
reset=`tput sgr0`
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`

## 
DIRECTORY=`dirname $0`
echo $DIRECTORY | xargs basename > /dev/null

# Function to print proper outputs 
function logger() {
    if [ $DEBUG == 'True' ]; then
        echo `tput setaf 3`"Debuging the script is on"
        echo "$1"`tput sgr0`
    else
        echo $2"INFO: $1"`tput sgr0`
    fi 
}

echo 
"""
######################################################################
################# STEP 1: UPLOAD SSH KEY TO GITHUB  ##################
######################################################################
"""

## Making sure ssh key generated!!
if [ -d ~/.ssh/ ]; then
    logger "==> SSH key already exists." $blue
else
    logger "It turns out you do not have an SSH key! Generating One ..." $yellow
    cat /dev/zero | ssh-keygen -q -N ""
    logger "+++ SSH key successfully generated in your laptop!!" $green
fi

## Adding user ssh key to github account
if [ -d ~/.ssh/ ]; then
    logger 'You need to upload your SSH public key to your GitHub account!' $yellow
    read -p "Enter github username: " githubuser
    read -s -p "Enter GitHub personal access tokens for $githubuser: " githubtoken
    echo "\n" 
    logger " Uploading the SSH key to GitHub" $yellow
    pub=`cat ~/.ssh/id_rsa.pub`
    curl -H "Authorization: token $githubtoken" -X POST -d "{\"title\":\"`hostname`\",\"key\":\"$pub\"}" https://api.github.com/user/keys
    logger "+++ Laptop SSH key successfully Uploaded/Already exists in GitHub" $green

fi

echo """
######################################################################
############## STEP 2: SYNC AUTHORIZED KEYS FROM GITHUB ##############
######################################################################
"""

## Sync all user authorized keys to laptop   
if [ -d ~/.ssh/ ]; then    
    read -p "Would you like to sync your SSH keys from your GitHub account? [y/n]: " key_answer
    if [[ $key_answer == [Yy] ]]; then
        logger 'Syncing the ssh-keys from github!!' $yellow
        curl --silent "https://github.com/$githubuser.keys" > ~/.ssh/authorized_keys 
        chmod 600 ~/.ssh/authorized_keys
        logger "+++ Your ssh-keys successfully synched from github!!" $green
    else
        logger "+++ Your ssh-keys were not synched from github!!" $red
    fi
fi

echo """
######################################################################
############### STEP 3: GENERATE FUCHICORP DIRECTORY #################
######################################################################
"""

## Generating fuchicorp folder
if [ -d $HOME/fuchicorp ]; then
    logger "==> fuchicorp folder already exists" $blue
else
    logger 'Creating fuchicorp folder!' $yellow
    `mkdir $HOME/fuchicorp` 
    logger "+++ fuchicorp folder successfully created in your laptop!!" $green 
fi
echo "NOTE: Navigate to your fuchicorp directory by running"
echo "      the following command:  $ cd ~/fuchicorp"

echo """
######################################################################
################# STEP 4: INSTALL REQUIRED PACKAGES ##################
######################################################################
"""

#1# Making sure brew installed!!
if which brew > /dev/null ; then
    logger "==> Homebrew already exists." $blue
else
    logger  "Installing brew command!!" $yellow
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    logger "+++ Homebrew successfully installed to your laptop!!" $green
fi 

#2# Making sure iTerm2 is installed!!
if [ -d "/Applications/iTerm.app" ] ; then
    logger "==> iTerm2 already exists." $blue
else
    logger 'Installing iterm2 to your laptop!!' $yellow
    brew install --cask iterm2
    logger "+++ iTerm2 successfully installed to your laptop!!" $green
fi

#3# Making sure wget is installed!!
if which wget > /dev/null ; then
    logger "==> wget already exists." $blue
else
    logger "Installing wget command!!" $yellow
    brew install wget
    logger "+++ wget successfully installed to your laptop!!" $green
fi

#4# Making sure Lens is installed!!
if [ -d "/Applications/Lens.app" ] ; then
    logger "==> Lens already exists." $blue 
else
    logger 'Installing Lens to your laptop!!' $yellow
    brew install --cask lens
    logger "+++ Lens successfully installed to your laptop!!" $green      
fi

#5# Making sure telnet is installed!!
if which telnet > /dev/null ; then
    logger "==> telnet already exists." $blue
else
    logger "Installing telnet to your laptop!!" $yellow
    brew install telnet
    logger "+++ telnet successfully installed to your laptop!!" $green
fi

#6# Making sure jq is installed!!
if which jq > /dev/null ; then
    logger "==> jq already exists." $blue
else
    logger "Installing jq to your laptop!!" $yellow
    brew install jq
    logger "+++ jq successfully installed to your laptop!!" $green
fi

#7# Making sure kubectl is installed!!
if which kubectl > /dev/null ; then
    logger "==> kubectl already exists." $blue
else
    logger "Installing kubernetes-cli to your laptop!!" $yellow
    brew install kubernetes-cli
    logger "+++ kubernetes-cli successfully installed to your laptop!!" $green
fi

#8# Making sure gcloud is installed!!
if which gcloud > /dev/null ; then
    logger "==> gcloud already exists." $blue
else
    logger "Installing gcloud to your laptop!!" $yellow
    brew install --cask google-cloud-sdk
    logger "+++ gcloud successfully installed to your laptop!!" $green
fi

#9# Making sure myzshr is installed!!
if [ $SHELL == '/bin/zsh' ]; then
    logger "==> oh-my-zsh already exists." $blue
else
    logger 'Installing oh-my-zsh to your laptop!!' $yellow
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    logger "+++ oh-my-zsh successfully installed to your laptop!!" $green
fi

#10# Making sure Visual Studio is installed!!
if [ -d "/Applications/Visual*.app" ] ; then
    logger "==> Visual Studio already exists." $blue
else
    logger 'Installing/Updating Visual Studio to your laptop!!' $yellow
    brew install --cask visual-studio-code
    logger "+++ Visual Studio successfully installed/updated in your laptop!!" $green 
fi

echo """
######################################################################
#################### END OF ONBOARDING SCRIPT  #######################
######################################################################
"""