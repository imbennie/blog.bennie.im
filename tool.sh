
#!/bin/bash

dir=~/blog
backup_dir=$dir/bennie.im
hexo_dir=$dir/hexo


function goBackupDir() {
	cd $backup_dir
}

function goHexoDir() {
	cd $hexo_dir
}


function cpFiles() {
  \cp -r source themes _config.yml _config.landscape.yml $backup_dir
}

function pushToGit() {
	git add .
	git status
	git commit -m "backup update."
	git push origin HEAD
}

function backUpData() {
	goHexoDir
	cpFiles
	
	goBackupDir
	pushToGit
}

function hexoDeploy() {
   goHexoDir
   hexo clean && hexo g -d
}

backUpData
hexoDeploy


