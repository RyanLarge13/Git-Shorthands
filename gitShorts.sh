#!bash/bin
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"
WHITE="\033[0;37m"
ENDCOLOR="\e[0m"

function gs {
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
		config
	fi
	if [[ $1 = "-H" || $1 = "-h" ]]; then
		showHelp
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
  CONFIG OPETIONS: 
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
	read -p "Repo name: " repoName
	read -p "Github username: " username
	read -p "Would you like us to install dependencies after cloning is finished? (Y/n): " installOrNot
	if [[ $installOrNot = "Y" || $installOrNot = "y" ]]; then
		echo "Sounds good!!"
		git clone git@github.com:$username/$repoName.git
		cd $repoName && npm install
	fi
	if [[ $installOrNot = "n" || $installOrNot = "N" ]]; then
		echo "No problem.. Cloning into repository now...."
		git clone git@github.com:$username/$repoName.git
		cd $repoName
	fi
}

function initRepo() {
	if [[ ! $1 ]]; then
		read -p "Please provide a repo name: " repo
		gs init $repo
	fi
	if [[ $1 ]]; then
	read -p "Github username: " username
		echo "Initializing a new repository now...."
		git init
		read -p "Do you want to add a README.md file? (Y/n)" yesOrNo
		if [[ $yesOrNo = "Y" || yesOrNo = "y" ]]; then
			touch README.md
			printf "# $repo" >README.md
		fi
		if [[ $yesOrNo = "N" || $yesOrNo = "n" ]]; then
			echo "Sounds good, initializing without a README file.."
		fi
		git add .
		git commit -m "Initial commit"
                git branch -M main
		git remote add origin git@github.com:$username/$repo.git
		git push -u origin main
		echo "Successful! You code base was pushed to the cloud.."
	fi
}
