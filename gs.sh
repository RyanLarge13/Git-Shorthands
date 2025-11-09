#!/usr/bin/env bash

#################################
# Color Config
#################################
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
BLUE=$'\033[0;34m'
PURPLE=$'\033[0;35m'
CYAN=$'\033[0;36m'
WHITE=$'\033[0;37m'
ENDCOLOR=$'\033[0m'

#################################
# User + Config
#################################
USER_HOME_DIR="$HOME"
CONFIG_FILE="$USER_HOME_DIR/.gitshorts_config"


#################################
# MAIN ENTRY: `gs`
# Handles all high-level commands
#################################
function gs() {

	# If config doesn't exist, guide user through setup
	if [[ ! -f "$CONFIG_FILE" ]]; then
		echo "No configuration file found. Let's set up your username and installer first."
		config username
		config installer
	fi

	# Load existing config
	if [[ -f "$CONFIG_FILE" ]]; then
		source "$CONFIG_FILE"
	fi

	#################################
	# Command Routing
	#################################

	# No args => show help
	if [[ ! $1 ]]; then
		showHelp

	# Clone repo
	elif [[ $1 = "clone" ]]; then
		if [[ $3 ]]; then cloneRepo "$2" "$3"; fi
		if [[ $2 ]]; then cloneRepo "$2"; fi
		if [[ ! $2 ]]; then cloneRepo; fi

	# git status
	elif [[ $1 = "-s" ]]; then
		status

	# git init wrapper
	elif [[ $1 = "init" ]]; then
		initRepo "$2"

	# git pull
	elif [[ $1 = "-p" ]]; then
		pullRepo

	# git merge
	elif [[ $1 = "-m" ]]; then
		if [[ ! $2 ]]; then mergeRepo; fi
		if [[ $2 ]]; then mergeRepo "$2"; fi

	# config username / installer
	elif [[ $1 = "conf" || $1 = "config" ]]; then

		if [[ ! $2 ]]; then
			printf "Change what?\n ${CYAN}1: username${ENDCOLOR} or ${CYAN}2: installer${ENDCOLOR}: "
			read confValue

			if [[ $confValue = "1" ]]; then
				config "username"
			elif [[ $confValue = "2" ]]; then
				config "installer"
			else
				printf "\n${RED}Invalid Option${ENDCOLOR}\n\n"
				gs "conf"
			fi
		fi

		if [[ $2 ]]; then
			config "$2"
		fi

	# Help
	elif [[ $1 = "-H" || $1 = "-h" || $1 = "help" ]]; then
		showHelp

	# Commit changes
	elif [[ $1 = "commit" ]]; then
		commitRepo

	# Version
	elif [[ $1 = "-v" || $1 = "version" ]]; then
		printf "gs 1.0.0"

	else
		createHelpFile "Invalid"
	fi
}



#################################
# Safety prompt: Retry prompt
#################################
function rerunScript() {
	printf "$1"
	read answer

	if [[ $answer =~ ^[Yy]$ ]]; then
		eval "$2"
	else
		printf "${RED}Command aborted${ENDCOLOR}\n"
	fi
}



#################################
# Prints help + creates help file
#################################
function createHelpFile() {
	clear

	if [[ $1 ]]; then
		printf "\n${RED}Invalid Argument${ENDCOLOR}\n\n"
	fi

	# Help text written to file
	cat <<EOF > "$USER_HOME_DIR/help.txt"

Welcome to ${RED}Git Shorts${ENDCOLOR}! Available commands:

${GREEN}gs${ENDCOLOR} ${BLUE}clone${ENDCOLOR} ${PURPLE}<repo>${ENDCOLOR}
    Clone a repository from your GitHub account.

${GREEN}gs${ENDCOLOR} ${BLUE}clone${ENDCOLOR} ${PURPLE}<repo>${ENDCOLOR} ${PURPLE}<username>${ENDCOLOR}
    Clone another user's repo.

${GREEN}gs${ENDCOLOR} ${BLUE}init${ENDCOLOR} ${YELLOW}<repo>${ENDCOLOR}
    Creates a repo locally and pushes to GitHub.

${GREEN}gs${ENDCOLOR} ${BLUE}-m${ENDCOLOR}
    Merge branches interactively.

${GREEN}gs${ENDCOLOR} ${BLUE}-p${ENDCOLOR}
    Pull latest changes.

${GREEN}gs${ENDCOLOR} ${BLUE}conf${ENDCOLOR} ${YELLOW}<key>${ENDCOLOR} ${CYAN}<value>${ENDCOLOR}
    Configure username or installer.

${GREEN}gs${ENDCOLOR} ${BLUE}commit${ENDCOLOR}
    Add, commit, and push changes.

${GREEN}gs${ENDCOLOR} ${BLUE}-v${ENDCOLOR}
    Show version.

${GREEN}gs${ENDCOLOR} ${BLUE}-H${ENDCOLOR}
    Show help file.

EOF

	cat "$USER_HOME_DIR/help.txt"
}



#################################
# Show help (uses file if exists)
#################################
function showHelp() {
	clear
	[[ ! -f "$USER_HOME_DIR/help.txt" ]] && createHelpFile
	cat "$USER_HOME_DIR/help.txt"
}



#################################
# Clone a repository
#################################
function cloneRepo() {
	question="Retry cloning? (Y/n): "

	# Ensure config exists
	[[ ! -f "$CONFIG_FILE" ]] && config username && config installer
	source "$CONFIG_FILE"

	# Repo name
	if [[ $1 ]]; then
		repoName="$1"
	else
		read -p "Repo name: " repoName
	fi

	printf "Install dependencies using ${GREEN}$INSTALLER${ENDCOLOR}? (Y/n): "
	read installOrNot

	# Clone logic (supports cloning from another user)
	if [[ $installOrNot =~ ^[Yy]$ ]]; then
		printf "${GREEN}Installing after clone...${ENDCOLOR}\n"
		git clone "git@github.com:${2:-$USERNAME}/$repoName.git" || rerunScript "$question" "cloneRepo"
		cd "$repoName" && $INSTALLER install
	else
		printf "Cloning ${GREEN}$repoName${ENDCOLOR}...\n"
		git clone "git@github.com:${2:-$USERNAME}/$repoName.git" || rerunScript "$question" "cloneRepo"
		cd "$repoName"
	fi
}



#################################
# Initialize a new local repository
#################################
function initRepo() {
	question="Try initializing again? (Y/n)"

	[[ ! -f "$CONFIG_FILE" ]] && config username && config installer
	source "$CONFIG_FILE"

	if [[ ! $1 ]]; then
		read -p "Repo name: " repo
		gs init "$repo"
		return
	fi

	repo="$1"
	echo "Initializing new repository..."

	git init || rerunScript "$question" "initRepo"
	read -p "Add README.md? (Y/n): " yesOrNo

	if [[ $yesOrNo =~ ^[Yy]$ ]]; then
		echo "# $repo" > README.md
		printf "${GREEN}README.md created${ENDCOLOR}\n"
	fi

	git add .
	git commit -m "Initial commit"
	git branch -M main
	git remote add origin "git@github.com:$USERNAME/$repo.git"
	git push -u origin main

	printf "${GREEN}Successfully pushed to repo${ENDCOLOR}\n"
}



#################################
# Add + Commit + Push
#################################
function commitRepo() {
	question="Re-run commit? (Y/n)"

	git add .    || rerunScript "$question" "commitRepo"
	git commit   || rerunScript "$question" "commitRepo"
	git push     || rerunScript "$question" "commitRepo"

	printf "${GREEN}Changes pushed!${ENDCOLOR}\n"
}



#################################
# git pull wrapper
#################################
function pullRepo() {
	question="Pull again? (Y/n)"
	git pull || rerunScript "$question" "pullRepo"
}



#################################
# git merge wrapper
#################################
function mergeRepo() {
	read -p "Main branch name: " branchName
	printf "Merge into ${GREEN}$branchName${ENDCOLOR}. Branch to merge: "
	read branchName2

	printf "Confirm merge? (Y/n): "
	read confirm

	if [[ $confirm =~ ^[Yy]$ ]]; then
		git checkout "$branchName"
		git pull
		git merge "$branchName2"
		git push
	else
		echo "Cancelled."
	fi
}



#################################
# git status wrapper
#################################
function status() {
	git status || rerunScript "Run git status again?" "status"
}



#################################
# Update configuration (username / installer)
#################################
function config() {

	# Ensure file exists
	[[ ! -f "$CONFIG_FILE" ]] && touch "$CONFIG_FILE"

	# Ensure keys exist
	grep -q "USERNAME=" "$CONFIG_FILE" || echo "USERNAME=" >> "$CONFIG_FILE"
	grep -q "INSTALLER=" "$CONFIG_FILE" || echo "INSTALLER=" >> "$CONFIG_FILE"

	if [[ $1 = "username" ]]; then
		read -p "New ${GREEN}username${ENDCOLOR}: " newUsername
		sed -i "s/USERNAME=.*/USERNAME=$newUsername/" "$CONFIG_FILE"
	fi

	if [[ $1 = "installer" ]]; then
		read -p "New ${GREEN}installer${ENDCOLOR}: " newInstaller
		sed -i "s/INSTALLER=.*/INSTALLER=$newInstaller/" "$CONFIG_FILE"
	fi
}


#################################
# Remove comment to export gs for shell use
#################################
export -f gs