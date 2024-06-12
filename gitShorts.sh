#!bin/bash
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"
WHITE="\033[0;37m"
ENDCOLOR="\e[0m"

USER_HOME_DIR=$HOME
CONFIG_FILE="$USER_HOME_DIR/.gitshorts_config"

function gs {
	if [[ ! -f "$CONFIG_FILE" ]]; then
		echo "No configuration file found. Let's set up your username and installer first."
		config username
		config installer
	fi
	if [[ -f "$CONFIG_FILE" ]]; then
		source "$CONFIG_FILE"
	fi
	if [[ ! $1 ]]; then
		showHelp
	elif [[ $1 = "clone" ]]; then
		if [[ $3 ]]; then
			cloneRepo $2 $3
		fi
		if [[ $2 ]]; then
			cloneRepo $2
		fi
		if [[ ! $2 ]]; then
			cloneRepo
		fi
	elif [[ $1 = "init" ]]; then
		initRepo $2
	elif [[ $1 = "-p" ]]; then
		pullRepo
	elif [[ $1 = "-m" ]]; then
		if [[ ! $2 ]]; then
			mergeRepo
		fi
		if [[ $2 ]]; then
			mergeRepo $2
		fi
	elif [[ $1 = "conf" ]]; then
		if [[ ! $2 ]]; then
			printf "Please provide which value you would like to change\n ${CYAN}username${ENDCOLOR} or ${CYAN}installer${ENDCOLOR}"
		fi
		if [[ $2 ]]; then
			config $2
		fi
	elif [[ $1 = "-H" || $1 = "-h" ]]; then
		showHelp
	elif [[ $1 = "commit" ]]; then
		commitRepo
	else
		createHelpFile "Invalid"
	fi
}

function createHelpFile() {
	touch ./help.txt
	clear
	if [[ $1 ]]; then
		printf "\n${RED}Invalid Argument${ENDCOLOR}\n\n"
	fi
	printf "
  Welcome to ${RED}Git Shorts${ENDCOLOR} help line...\nHere is a list of commands that can be ran with gs\n
  COLOR TABLE: 
  [
    ${GREEN}GREEN${ENDCOLOR} - gs
    ${BLUE}BLUE${ENDCOLOR} - command
    ${YELLOW}YELLOW${ENDCOLOR} - arguments || key
    ${CYAN}CYAN${ENDCOLOR} - arguments || value
	${PURPLE}PURPLE${ENDCOLOR} - optional argument
  ]\n
  CONFIG OPTIONS: 
  [
    ${YELLOW}KEY${ENDCOLOR}: <username>, ${CYAN}VALUE${ENDCOLOR}: <Your github username>
    ${YELLOW}KEY${ENDCOLOR}: <installer>, ${CYAN}VALUE${ENDCOLOR}: <npm, yarn, etc...>
  ]\n
  ${GREEN}gs${ENDCOLOR} ${BLUE}clone${ENDCOLOR} ${PURPLE}<repo name>${ENDCOLOR} -- This will clone an exsisting 
  repository within your github account.\n
  ${GREEN}gs${ENDCOLOR} ${BLUE}clone${ENDCOLOR} ${PURPLE}<repo name>${ENDCOLOR} ${PURPLE}<git hub username>${ENDCOLOR} -- This will clone a repo from another users repository\n
  ${GREEN}gs${ENDCOLOR} ${BLUE}init${ENDCOLOR} ${YELLOW}<repo name>${ENDCOLOR} -- This command will initialize a new local 
  repository and connect it with an exsiting new repo
  on github.\n
  ${GREEN}gs${ENDCOLOR} ${BLUE}-p${ENDCOLOR} -- Run git pull to update your local repo\n
  ${GREEN}gs${ENDCOLOR} ${BLUE}conf${ENDCOLOR} ${YELLOW}<key>${ENDCOLOR} ${CYAN}<value>${ENDCOLOR} -- To customize your experience
  and add or change values to your gs configuration file, use
  this command to configure each value so gs knows
  what to use when running your commands. 
  ${RED}See config option above..${ENDCOLOR}\n
  ${GREEN}gs${ENDCOLOR} ${BLUE}commit${ENDCOLOR} -- To commit your working directory and all files within it to the remote repository\n
  ${GREEN}gs${ENDCOLOR} ${BLUE}-H${ENDCOLOR} -- Print this help page.\n
  " >help.txt
	cat "./help.txt"
}

function showHelp() {
	if [[ ! -f "./help.txt" ]]; then
		createHelpFile
	else
		clear
		cat "./help.txt"
	fi
}

function cloneRepo() {
	if [[ ! -f "$CONFIG_FILE" ]]; then
		echo "No configuration file found. Let's set up your username and installer first."
		config username
		config installer
	fi
	if [[ -f "$CONFIG_FILE" ]]; then
		source "$CONFIG_FILE"
	fi
	if [[ $1 ]]; then
		repoName="$1"
	else
		read -p "Repo name: " repoName
	fi
	if [[ $INSTALLER = "npm" ]]; then
		read -p "Would you like us to install dependencies with npm after cloning is finished? (Y/n): " installOrNot
	fi
	if [[ $installOrNot = "Y" || $installOrNot = "y" ]]; then
		echo "Sounds good!"
		if [[ $2 ]]; then
			git clone git@github.com:$2/$repoName.git
			if [[ ! $? -eq 0 ]]; then 
			  echo "${RED}Clone failed${ENDCOLOR} with a status code: ${RED}$?${ENDCOLOR}"
			  read -p "Would you like to try cloning again (Y/n)? " tryCloneAgain
			  if [[ try Clone Again = "Y" ||    tryCloneAgain = "y" ]]; then
			    cloneRepo $1 $2
			  else 
			    echo "Canceling clone command"
			  fi
			fi
		else
			git clone git@github.com:$USERNAME/$repoName.git
			cd $repoName && $INSTALLER install
		fi
	fi
	if [[ $installOrNot = "n" || $installOrNot = "N" ]]; then
		echo "No problem.. Cloning into repository now...."
		if [[ $2 ]]; then
			git clone git@github.com:$2/$repoName.git
		else
			git clone git@github.com:$USERNAME/$repoName.git
			cd $repoName
		fi
	fi
}

function initRepo() {
	if [[ ! -f "$CONFIG_FILE" ]]; then
		echo "No configuration file found. Let's set up your username and installer first."
		config username
		config installer
	fi
	if [[ -f "$CONFIG_FILE" ]]; then
		source "$CONFIG_FILE"
	fi
	if [[ ! $1 ]]; then
		read -p "Please provide a repo name: " repo
		gs init $repo
	fi
	if [[ $1 ]]; then
		if [[ ! $USERNAME ]]; then
			read -p "Github username: " username
		fi
		echo "Initializing a new repository now...."
		git init
		read -p "Do you want to add a README.md file? (Y/n)" yesOrNo
		if [[ $yesOrNo = "Y" || $yesOrNo = "y" ]]; then
			touch README.md
			echo "# $repo" >README.md
		fi
		if [[ $yesOrNo = "N" || $yesOrNo = "n" ]]; then
			echo "Sounds good, initializing without a README file.."
		fi
		git add .
		git commit -m "Initial commit"
		git branch -M main
		git remote add origin git@github.com:$USERNAME/$repo.git
		git push -u origin main
		echo "Successful! Your code base was pushed to the cloud.."
	fi
}

function commitRepo() {
	git add .
	git commit
	git push
	if [[ $? -eq 0 ]]; then
		echo "Successfully pushed updated files to your remote repository."
	else
		echo "${RED}Commit failed${ENDCOLOR} with a status code: ${RED}$?${ENDCOLOR}"
	fi
}

function pullRepo() {
	git pull
	if [[ $? -eq 0 ]]; then
		echo "Local repository is now up to date."
	else
		echo "${RED}Pull failed${ENDCOLOR} with a status code: ${RED}$?${ENDCOLOR}"
	fi
}

function mergeRepo() {
	if [[ $1 ]]; then
		branchName ="$1"
	else
		read -p "What branch do you wish to merge? " branchName
	fi
	read -p "Do you confirm? Merge current branch with branch
 ${GREEN}$branchName${ENDCOLOR}? (Y/n) " confirm
	if [[ $confirm = "Y" || $confirm = "y" ]]; then
		printf "\nSounds good. Merging with branch ${GREEN}$branchName${ENDCOLOR}\n"
		git merge $branchName
		if [[ $? -eq 0 ]]; then
			printf "\nSuccesfully merged with branch ${GREEN}$branchName${ENDCOLOR}\n"
		else
			printf "\n${RED}Merge failed${ENDCOLOR} with a status code: ${RED}$?${ENDCOLOR}\n"
			read -p "Would you like to retry the merge? (Y/n) " remerge
			if [[ $remerge = "Y" || $remerge = "y" ]]; then
				echo "${GREEN}$remerge${ENDCOLOR} Sounds good."
				mergeRepo $branchName
			else
				echo "Okay. Canceling merge"
			fi
		fi
	else
		echo "Canceling merge"
	fi
}

function config() {
	if [[ ! -f "$CONFIG_FILE" ]]; then
		touch "$CONFIG_FILE"
		if [ $? -eq 0 ]; then
			echo "${GREEN}Configuration file created successfully.${ENDCOLOR}"
		else
			echo "${RED}Failed to create configuration file.${ENDCOLOR}"
		fi
	fi
	if ! grep -q "USERNAME=" "$CONFIG_FILE"; then
		echo "USERNAME=" >>"$CONFIG_FILE"
	fi
	if ! grep -q "INSTALLER=" "$CONFIG_FILE"; then
		echo "INSTALLER=" >>"$CONFIG_FILE"
	fi
	if [[ $1 = "username" ]]; then
		read -p "What would you like your new ${GREEN}username${ENDCOLOR} to be??: " newUsername
		sed -i "s/USERNAME=.*/USERNAME=$newUsername/" "$CONFIG_FILE"
		echo "Your new username was set to $newUsername"
	fi
	if [[ $1 = "installer" ]]; then
		read -p "What ${GREEN}installer${ENDCOLOR} will you be using by default?: " newInstaller
		sed -i "s/INSTALLER=.*/INSTALLER=$newInstaller/" "$CONFIG_FILE"
		echo "Your new installer was set to $newInstaller"
	fi
}

export -f gs
