#!/bin/bash

function initRepo() {
	git init
	git add .
	git commit -m 'Initial commit.'
	git branch -M main
	echo Remote name?
	read repo
echo Github Username?
read username
	git remote add origin git@github.com:$username/$repo.git
	git push -u origin main
}