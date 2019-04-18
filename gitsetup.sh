#!/bin/sh
BANNER=⏺⏺⏺⏺⏺
 
GITEMAIL=$1
 
if [ ! -x "$(command -v "git")" ]; then
 echo "$BANNER Git not found, installing git"
 sudo apt -y install git
fi

if [ ! -x "$(command -v "sshd")" ]; then
 echo "$BANNER OpenSSH not found, installing openssh-server"
 sudo apt -y install openssh-server
fi

SETGIT=`which git`
echo $BANNER Using $SETGIT

SETOS=`uname | tr '[:upper:]' '[:lower:]'`
echo $BANNER OS is $SETOS

SETGITNAME=`uname -a`
echo $BANNER GITNAME is $SETGITNAME

if [ ! -f ~/.gitcfg/config ]; then
 echo $BANNER  Creating new repo 
 git init --bare $HOME/.gitcfg
fi

echo "alias gitc='$SETGIT --git-dir=$HOME/.gitcfg/ --work-tree=$HOME'" >> $HOME/.bashrc
alias gitc='$SETGIT --git-dir=$HOME/.gitcfg/ --work-tree=$HOME'
echo ".gitcfg" >> ~/.gitignore

echo $BANNER Settings
gitc config --local status.showUntrackedFiles no
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=7200'
git config --global user.email "$SETGITEMAIL"
git config --global user.name "$SETGITNAME"

echo $BANNER Remote will be https://github.com/c0f/$SETOS.git
gitc remote add origin https://github.com/c0f/$SETOS.git

echo $BANNER Git Config
gitc config --list | cat

echo $BANNER Git Remote Settings
gitc remote -v

echo $BANNER Git Status
gitc status

echo "alias gitc='$SETGIT --git-dir=$HOME/.gitcfg/ --work-tree=$HOME'" >> ~/.bashrc

echo $BANNER Use this alias, then gitc clone
echo "rm .bashrc .gitignore .profile .Xdefaults"
echo "alias gitc='$SETGIT --git-dir=$HOME/.gitcfg/ --work-tree=$HOME'"
echo "gitc pull origin master"
echo " "

