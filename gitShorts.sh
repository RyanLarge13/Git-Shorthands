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

function rerunScript() {
	read -p $1 answer
	if [[ $anser =~ ^[Yy]$ ]]; then
		eval $2
	else
		echo "Aborted"
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
				if [[ tryCloneAgain = "Y" || tryCloneAgain = "y" ]]; then
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
	fi
	if [[ $1 ]]; then
		if [[ ! $USERNAME ]]; then
			read -p "Github username: " username
		fi
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
				echo "${RED}Could not create README.md file for your project.${ENDCOLOR}"
			else
				echo "# $repo" >README.md
				echo "${GREEN}Successfully generated README.md file${ENDCOLOR}"
			fi
		else
			echo "Sounds good, initializing ${RED}without${ENDCOLOR} a README.md file.."
		fi
		git add .
		if [[ $? -ne 0 ]]; then
			printf "${RED}git add .${ENDCOLOR} failed with a status code: ${RED}$?${ENDCOLOR}"
			rerunScript $question "initRepo"
		fi
		git commit -m "Initial commit"
		if [[ $? -ne 0 ]]; then
			printf "${RED}git commit -m${ENDCOLOR} failed with a status code: ${RED}$?${ENDCOLOR}"
			rerunScript $question "initRepo"
		fi
		git branch -M main
		if [[ $? -ne 0 ]]; then
			printf "${RED}git branch -M${ENDCOLOR} failed with a status code: ${RED}$?${ENDCOLOR}"
			rerunScript $question "initRepo"
		fi
		git remote add origin git@github.com:$USERNAME/$repo.git
		if [[ $? -ne 0 ]]; then
			printf "${RED}git remote add origin <origin>${ENDCOLOR} failed with a status code: ${RED}$?${ENDCOLOR}"
			rerunScript $question "initRepo"
		fi
		git push -u origin main
		if [[ $? -ne 0 ]]; then
			printf "${RED}git push -u${ENDCOLOR} failed with a status code: ${RED}$?${ENDCOLOR}"
			rerunScript $question "initRepo"
		fi
		# pick up on this function
		echo "Successful! Your code base was pushed to the cloud.."
	fi
}

function commitRepo() {
	git add .
	question="Would you like to re-run this commit?"
	if [[ $? -ne 0 ]]; then
		printf "${RED}git add .${ENDCOLOR} failed with a status code: ${RED}$?${ENDCOLOR}/n"
		rerunScript $question "$commitRepo"
		return 1
	fi
	git commit
	if [[ $? -ne 0 ]]; then
		printf "${RED}git commit${ENDCOLOR} failed with a status code: ${RED}$?${ENDCOLOR}/n"
		rerunScript $question "$commitRepo"
		return 1
	fi
	git push
	if [[ $? -ne 0 ]]; then
		printf "${RED}git push${ENDCOLOR} failed with a status code: ${RED}$?${ENDCOLOR}/n"
		rerunScript $question "commitRepo"
		return 1
	fi
	echo "Successfully pushed local changes to your remote repository."
	return 0
}

function pullRepo() {
	git pull
	if [[ $? -eq 0 ]]; then
		echo "Local repository is now up to date."
		return 0
	else
		printf "${RED}Pull failed${ENDCOLOR} with a status code: ${RED}$?${ENDCOLOR}\n"
		question="Would you like to pull again? (Y/n)"
		rerunScript $question "pullRepo"
		return 1
	fi
}

function mergeRepo() {
	question="Would you like to retry this merge?"
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
			return 0
		else
			printf "\n${RED}Merge failed${ENDCOLOR} with a status code: ${RED}$?${ENDCOLOR}\n"
			rerunScript $question "mergeRepo"
			return 1
		fi
	else
		echo "Canceling merge"
		return 0
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
