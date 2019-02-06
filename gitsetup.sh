#!/bin/sh
SETGIT=`which git`
SETOS=`uname | tr '[:upper:]' '[:lower:]'`
SETGITNAME=`uname -a`

if [ ! -f ~/.gitcfg/config ]; then
 git init --bare $HOME/.gitcfg
fi

echo "alias gitc='$SETGIT --git-dir=$HOME/.gitcfg/ --work-tree=$HOME'" >> $HOME/.bashrc
alias gitc='$SETGIT --git-dir=$HOME/.gitcfg/ --work-tree=$HOME'
echo ".gitcfg" >> ~/.gitignore

gitc config --local status.showUntrackedFiles no
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=7200'
git config --global user.email "c0f@c0f.c0f"
git config --global user.name "$SETGITNAME"

gitc remote add origin https://github.com/c0f/$SETOS.git

gitc config --list | cat

gitc remote -v

gitc status

echo "alias gitc='$SETGIT --git-dir=$HOME/.gitcfg/ --work-tree=$HOME'"
echo " "
echo "gitc pull origin master - but existing files will need to be cleared first"
echo " "
