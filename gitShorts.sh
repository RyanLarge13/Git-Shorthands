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
	elif [[ $1 = "-s" ]]; then
		status
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

function rerunScript() {
	read -p $1 answer
	if [[ $anser =~ ^[Yy]$ ]]; then
		eval $2
	else
		printf "${RED}Command aborted${ENDCOLOR}\n"
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
  ${GREEN}gs${ENDCOLOR} ${BLUE}-m${ENDCOLOR} ${PURPLE}<branch with latest changes>${ENDCOLOR} -- this will merge the branch you specify first
  (the one with the latest changes eg. dev branch) with the the branch you specify next (the branch you want to inherit the changes to eg. main wants to merge  branch dev changes). \n
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
	question="Would you like to try cloning (Y/n)? "
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
	read -p "Would you like us to install dependencies with ${GREEN}$INSTALLER${ENDCOLOR} after cloning is finished? (Y/n): " installOrNot
	if [[ $installOrNot = "Y" || $installOrNot = "y" ]]; then
		echo "Sounds good!"
		if [[ $2 ]]; then
			git clone git@github.com:$2/$repoName.git
			if [[ ! $? -eq 0 ]]; then
				rerunScript $question "cloneRepo"
				return 1
			fi
		else
			git clone git@github.com:$USERNAME/$repoName.git
			if [[ ! $? -eq 0 ]]; then
				rerunScript $question "cloneRepo"
				return 1
			fi
			printf "${GREEN}Insatlling deps...${ENDCOLOR}\n"
			cd $repoName && $INSTALLER install
		fi
	fi
	if [[ $installOrNot = "n" || $installOrNot = "N" ]]; then
		printf "No problem. Cloning into ${GREEN}$repoName${ENDCOLOR}\n"
		if [[ $2 ]]; then
			git clone git@github.com:$2/$repoName.git
			if [[ ! $? -eq 0 ]]; then
				rerunScript $question "cloneRepo"
				return 1
			fi
		else
			git clone git@github.com:$USERNAME/$repoName.git
			if [[ ! $? -eq 0 ]]; then
				rerunScript $question "cloneRepo"
				return 1
			fi
			cd $repoName
		fi
	fi
	return 0
}

function initRepo() {
	question="Would you like to try initializing again? (Y/n)"
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
		if [[ $? -ne 0 ]]; then
			printf "${RED}git init${ENDCOLOR} failed with a status code: ${RED}$?${ENDCOLOR}\n"
			rerunScript $question "initRepo"
			return 1
		fi
		return 0
	fi
	if [[ $1 ]]; then
		echo "Initializing a new repository now...."
		git init
		if [[ $? -ne 0 ]]; then
			printf "${RED}git init failed${ENDCOLOR} with a status code: ${RED}$?${ENDCOLOR}\n"
			rerunScript $question "initRepo"
			return 1
		fi
		read -p "Do you want to add a README.md file? (Y/n)" yesOrNo
		if [[ $yesOrNo = "Y" || $yesOrNo = "y" ]]; then
			touch README.md
			if [[ $? -ne 0 ]]; then
				printf "${RED}Could not create README.md file for your project.${ENDCOLOR}\n"
			else
				echo "# $repo" >README.md
				printf "${GREEN}Successfully generated README.md file${ENDCOLOR}\n"
			fi
		else
			printf "Sounds good, initializing ${RED}without${ENDCOLOR} a README.md file..\n"
		fi
		git add .
		if [[ $? -ne 0 ]]; then
			printf "${RED}git add .${ENDCOLOR} failed with a status code: ${RED}$?${ENDCOLOR}"
			rerunScript $question "initRepo"
			return 1
		fi
		git commit -m "Initial commit"
		if [[ $? -ne 0 ]]; then
			printf "${RED}git commit -m${ENDCOLOR} failed with a status code: ${RED}$?${ENDCOLOR}"
			rerunScript $question "initRepo"
			return 1
		fi
		git branch -M main
		if [[ $? -ne 0 ]]; then
			printf "${RED}git branch -M${ENDCOLOR} failed with a status code: ${RED}$?${ENDCOLOR}"
			rerunScript $question "initRepo"
			return 1
		fi
		git remote add origin git@github.com:$USERNAME/$repo.git
		if [[ $? -ne 0 ]]; then
			printf "${RED}git remote add origin <origin>${ENDCOLOR} failed with a status code: ${RED}$?${ENDCOLOR}"
			rerunScript $question "initRepo"
			return 1
		fi
		git push -u origin main
		if [[ $? -ne 0 ]]; then
			printf "${RED}git push -u origin main${ENDCOLOR} failed with a status code: ${RED}$?${ENDCOLOR}"
			rerunScript $question "initRepo"
			return 1
		fi
		printf "${GREEN}Successful${ENDCOLOR}. Your code base was pushed to the cloud.\n"
		return 0
	fi
}

function commitRepo() {
	question="Would you like to re-run this commit?"
	git add .
	if [[ $? -ne 0 ]]; then
		printf "${RED}git add .${ENDCOLOR} failed with a status code: ${RED}$?${ENDCOLOR}\n"
		rerunScript $question "$commitRepo"
		return 1
	fi
	git commit
	if [[ $? -ne 0 ]]; then
		printf "${RED}git commit${ENDCOLOR} failed with a status code: ${RED}$?${ENDCOLOR}\n"
		rerunScript $question "$commitRepo"
		return 1
	fi
	git push
	if [[ $? -ne 0 ]]; then
		printf "${RED}git push${ENDCOLOR} failed with a status code: ${RED}$?${ENDCOLOR}\n"
		rerunScript $question "commitRepo"
		return 1
	fi
	printf "${GREEN}Successfully pushed${ENDCOLOR} local changes to your remote repository\n"
	return 0
}

function pullRepo() {
	question="Would you like to pull again? (Y/n)"
	git pull
	if [[ $? -eq 0 ]]; then
		printf "Local repository is now ${GREEN}up to date${ENDCOLOR}.\n"
		return 0
	else
		printf "${RED}Pull failed${ENDCOLOR} with a status code: ${RED}$?${ENDCOLOR}\n"
		rerunScript $question "pullRepo"
		return 1
	fi
}

function mergeRepo() {
	question ="Would you like to retry this merge?"
	if [[ $1 ]]; then
		branchName ="$1"
	else
		read -p "What is the name of the main branch? " branchName
	fi
	read -p "What branch would you like to merge with ${GREEN}$branchName${ENDCOLOR}? " branchName2
	read -p "Do you confirm? Merge
 ${GREEN}$branchName${ENDCOLOR} with branch ${GREEN}$branchName2${ENDCOLOR}? (Y/n) " confirm
	if [[ $confirm = "Y" || $confirm = "y" ]]; then
		printf "\nSounds good. Merging...."
		git checkout $branchName
		git pull
		git merge $branchName2
		git push
		git checkout $branchName2
	else
		echo "Canceling merge"
		return 0
	fi
}

function status() {
	question = "Would you like to re-run git status?"
	git status
	if [[ $? -ne 0 ]]; then
		printf "${RED}git status${ENDCOLOR} failed with a status code: ${RED}$?${ENDCOLOR}\n"
		rerunScript $question "status"
	fi
}

function config() {
	if [[ ! -f "$CONFIG_FILE" ]]; then
		touch "$CONFIG_FILE"
		if [ $? -eq 0 ]; then
			printf "${GREEN}Configuration file created successfully.${ENDCOLOR}\n"
		else
			printf "${RED}Failed to create configuration file.${ENDCOLOR}\n"
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
		printf "Your new username was set to ${GREEN}$newUsername${ENDCOLOR}\n"
	fi
	if [[ $1 = "installer" ]]; then
		read -p "What ${GREEN}installer${ENDCOLOR} will you be using by default?: " newInstaller
		sed -i "s/INSTALLER=.*/INSTALLER=$newInstaller/" "$CONFIG_FILE"
		printf "Your new installer was set to ${GREEN}$newInstaller${ENDCOLOR}\n"
	fi
}

export -f gs
