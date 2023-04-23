#!bin/bash

CONFIG=./.gitshorts.config
USERNAME=null

if [[ -f $CONFIG ]]; then
	. $PWD/.gitshorts.config
	echo $username
fi
if [[ ! -f $CONFIG ]]; then
	touch .gitshorts.config
	chmod 700 ./.gitshorts.config
	echo "Starting setup"
	read -p "What is your Github username? " user
	printf "initialized=true\nusername=$user" >>./.gitshorts.config
	echo "You are all set. type -H for help menu"
	$USERNAME=user
	echo $USERNAME
fi

function cloneRepo() {
	read -p "Repo name: " repoName
	read -p "Would you like us to install dependencies after cloning is finished? (Y/n): " installOrNot
	if [[ $installOrNot = "Y" || $installOrNot = "y" ]]; then
		echo "Sounds good!!"
		git clone git@github.com:$USERNAME/$repoName.git
		cd $repoName && npm install
	fi
	if [[ $installOrNot = "n" || $installOrNot = "N" ]]; then
		echo "No problem.. Cloning into repository now...."
		git clone git@github.com:$USERNAME/$repoName.git
	fi
}

function initRepo() {
	git init
	git add .
	git commit -m 'Initial commit.'
	git branch -M main
	read -p "Remote name? " repo
	git remote add origin git@github.com:$USERNAME/$repo.git
	git push -u origin main
}
