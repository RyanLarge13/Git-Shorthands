# Git-Shorthands

Git Shorthands was built to make some of the longer git commands even easier than they already are...

So far the code written for this repo works only on linux terminals

**~/ gs clone ${REPO NAME}**

**_Clone remote repository_**

You will be asked if you would like to install project dependencies from the
root directory of your project after cloning from a repository

_the package manager set in configuration will be used_

**~/ gs init ${NAME OF REMOTE REPO}**

**_Initialize your local repository and push all changes to remote repository_**

This command only works if a repository exists remotely

**~/ gs -p**

**_Update local repository with most up to date code from remote_**

This command will run git pull and update your local repository. No other pull configurations
are accepted at this time

**~/ gs -m ${BRANCH NAME}**

**_Merge current branch with a local branch_**

This command is nearly useless. It is almost no less typing than original git command.. hmm
Will have to change that at some point. It still works though
