# Git-Shorthands

Git Shorthands was built to make some of the longer git commands even easier than they already are...

So far the code written for this repo works only on linux terminals and supplied two functions. 

1. Cloning into repositories. Only a Node.js repo is compatable for installing project dependencies with npm.
2. Initializing a new local git repository connection if the repository already exsists on your online account.

Initially when the program loads, it will check to see if a .gitShorts.config file exsists in the current directory. If the file does not
exsist, bash will create one and store non sensitive credentials to your github account. This allows the program to retreive stored data
and make the commands even easier.
