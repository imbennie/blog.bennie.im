
#!/bin/zsh


dir=/c/Users/Bennie/iCloudDrive/Documents/Blog

function goToWorkDir() {
   cd $dir
}


function rmOld() {
  cd $dir/bennie.im
  rm -fr source themes
}


function cpData() {
  \cp -r source themes _config.yml _config.landscape.yml ../bennie.im/
}

function backUpData() {
  cd $dir/hexo
  cpData
}


function gitpush() {
   git add .
   git commit -m "backup update."
   git push
}

goToWorkDir
rmOld
backUpData




