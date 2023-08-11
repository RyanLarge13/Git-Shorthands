#!bin/bash
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"
WHITE="\033[0;37m"
ENDCOLOR="\e[0m"

function gs {
	if [[ ! -f ./gitshorts_config ]]; then
		echo "No configuration file found. Let's set up your username and installer first."
		config username
		config installer
	fi
	if [[ -f ./gitshorts_config ]]; then
		source ./gitshorts_config
	fi
	if [[ ! $1 ]]; then
		showHelp
	fi
	if [[ $1 = "clone" ]]; then
		cloneRepo
	fi
	if [[ $1 = "init" ]]; then
		initRepo $2
	fi
	if [[ $1 = "conf" ]]; then
		if [[ ! $2 ]]; then
			echo "\nPlease provide which value you would like to change ${CYAN}username${ENDCOLOR} or ${CYAN}installer${ENDCOLOR}"
		fi
		if [[ $2 ]]; then
			config $2
		fi
	fi
	if [[ $1 = "-H" || $1 = "-h" ]]; then
		showHelp
	fi
	if [[ $1 = "commit" ]]; then
		commitRepo
	fi
}

function createHelpFile() {
	touch ./help.txt
	clear
	printf "
  Welcome to ${RED}Git Shorts${ENDCOLOR} help line...\nHere is a list of commands that can be ran with gs\n
  COLOR TABLE: 
  [
    ${GREEN}GREEN${ENDCOLOR} - gs
    ${BLUE}BLUE${ENDCOLOR} - command
    ${YELLOW}YELLOW${ENDCOLOR} - arguments || key
    ${CYAN}CYAN${ENDCOLOR} - arguments || value
  ]\n
  CONFIG OPTIONS: 
  [
    ${YELLOW}KEY${ENDCOLOR}: <username>, ${CYAN}VALUE${ENDCOLOR}: <Your github username> || <false> to ommit
    ${YELLOW}KEY${ENDCOLOR}: <installer>, ${CYAN}VALUE${ENDCOLOR}: <npm, yarn, etc...> || <false> to ommit
  ]\n
  ${GREEN}gs${ENDCOLOR} ${BLUE}clone${ENDCOLOR} -- This will clone an exsisting 
  repository within your github account.\n
  ${GREEN}gs${ENDCOLOR} ${BLUE}init${ENDCOLOR} ${YELLOW}<repo name>${ENDCOLOR} -- This command will initialize a new local 
  repository and connect it with an exsiting new repo
  on github.\n
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
	if [[ ! -f ./gitshorts_config ]]; then
		echo "No configuration file found. Let's set up your username and installer first."
		config username
		config installer
	fi
	if [[ -f ./gitshorts_config ]]; then
		source ./gitshorts_config
	fi
	read -p "Repo name: " repoName
	if [[ $INSTALLER = "npm" ]]; then
		read -p "Would you like us to install dependencies after cloning is finished? (Y/n): " installOrNot
	fi
	if [[ $installOrNot = "Y" || $installOrNot = "y" ]]; then
		echo "Sounds good!!"
		git clone git@github.com:$USERNAME/$repoName.git
		cd $repoName && $INSTALLER install
	fi
	if [[ $installOrNot = "n" || $installOrNot = "N" ]]; then
		echo "No problem.. Cloning into repository now...."
		git clone git@github.com:$USERNAME/$repoName.git
		cd $repoName
	fi
}

function initRepo() {
	if [[ ! -f ./gitshorts_config ]]; then
		echo "No configuration file found. Let's set up your username and installer first."
		config username
		config installer
	fi
	if [[ -f ./gitshorts_config ]]; then
		source ./gitshorts_config
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
	echo "\nSuccessfully pushed updated files to your remote repository.."
}

function config() {
	if [[ $1 = "username" ]]; then
		read -p "What would you like your new username to be??: " newUsername
		sed -i "s/USERNAME=.*/USERNAME=$newUsername/" ./gitshorts_config
		echo "Your new username was set to $newUsername"
	fi
	if [[ $1 = "installer" ]]; then
		read -p "What installer will you be using by default?: " newInstaller
		sed -i "s/INSTALLER=.*/INSTALLER=$newInstaller/" ./gitshorts_config
		echo "Your new installer was set to $newInstaller"
	fi
}

export -f gs
