function cloneRepo () {
	echo Repo Name?
	read repoName
	echo Username? 
	read username
	git clone git@github.com:$username/$repoName.git
}