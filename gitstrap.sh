#!/bin/sh
# Banner
B=[][][][]

if [ -z "$1" ]; then
 echo "$B Enter Github email address as command line parameter"
 exit 
else
 GITEMAIL=$1
 echo "$B GITEMAIL is $GITEMAIL"
fi

if [ ! -x "$(command -v "git")" ]; then
 echo "$B Git not found, installing git"
 sudo apt -y install git
fi

if [ ! -x "$(command -v "sshd")" ]; then
 echo "$B OpenSSH not found, installing openssh-server"
 sudo apt -y install openssh-server
fi

SETGIT=`which git`
echo $B Using $SETGIT

SETOS=`uname | tr '[:upper:]' '[:lower:]'`
echo $B OS is $SETOS

SETGITNAME=`uname -a`
echo $B GITNAME is $SETGITNAME

if [ ! -f ~/.gitcfg/config ]; then
 echo $B  Creating new repo 
 git init --bare $HOME/.gitcfg
fi

echo "alias gitc='$SETGIT --git-dir=$HOME/.gitcfg/ --work-tree=$HOME'" >> $HOME/.bashrc
alias gitc='$SETGIT --git-dir=$HOME/.gitcfg/ --work-tree=$HOME'
echo ".gitcfg" >> ~/.gitignore

echo $B Settings
gitc config --local status.showUntrackedFiles no
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=7200'
git config --global user.email "$SETGITEMAIL"
git config --global user.name "$SETGITNAME"
git config --global user.username c0f

echo $B Remote will be https://github.com/c0f/$SETOS.git
gitc remote add origin https://github.com/c0f/$SETOS.git

echo $B Git Config
gitc config --list | cat

echo $B Git Remote Settings
gitc remote -v

echo $B Git Status
gitc status

echo "alias gitc='$SETGIT --git-dir=$HOME/.gitcfg/ --work-tree=$HOME'" >> ~/.bashrc

echo $B Use this alias, then gitc clone
echo "rm .bashrc .gitignore .profile .Xdefaults .config/kateschemarc .config/kglobalshortcutsrc .config/kwinrc .config/konsolerc"
echo "rm .config/openbox/lxqt-rc.xml .config/pcmanfm-qt/lxqt/settings.conf .config/qterminal.org/qterminal.ini"
echo "rm .xscreensaver .config/lxterminal/lxterminal.conf
echo "alias gitc='$SETGIT --git-dir=$HOME/.gitcfg/ --work-tree=$HOME'"
echo "gitc pull origin master"
echo " "

