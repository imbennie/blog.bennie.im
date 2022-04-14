
#!/bin/zsh


dir=~/blog
backup_dir=$dir/bennie.im
hexo_dir=$dir/hexo


function goBackupDir() {
	cd $backup_dir
}

function goHexoDir() {
	cd $hexo_dir
}


function cpData() {
  \cp -r source themes _config.yml _config.landscape.yml ../bennie.im/
}

function backUpData() {
	goHexoDir
	\cp -a source themes _config.yml _config.landscape.yml $backup_dir
}


function gitpush() {
   git add .
   git commit -m "backup update."
   git push origin HEAD:file_backup
}

backUpData
gitpush



