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
echo "$B Using $SETGIT"

SETOS=`uname | tr '[:upper:]' '[:lower:]'`
echo "$B OS is $SETOS"

SETGITNAME=`uname -a`
echo "$B GITNAME is $SETGITNAME"

# ssh key setup
if [ ! -f $HOME/.ssh/github ]; then
 echo "$B Attempting to copy key from another host"
 mkdir -p $HOME/.ssh
 scp -T pi@10.0.0.1:"/home/pi/.ssh/githu* /home/pi/.ssh/config" $HOME/.ssh/
 chmod 600 $HOME/.ssh/github
 chmod 644 $HOME/.ssh/github.pub
 chmod 644 $HOME/.ssh/config
fi

if [ ! -d $HOME/.ssh ]; then
 echo "$B Creating ~/.ssh because it does not exist"
 mkdir $HOME/.ssh
 chmod 700 $HOME/.ssh
fi

if [ ! -f $HOME/.ssh/github ]; then
 echo "$B Paste github PRIVATE key, waiting 3s"
 sleep 2
 nano $HOME/.ssh/github
 chmod 600 $HOME/.ssh/github
fi

if [ ! -f $HOME/.ssh/github.pub ]; then
 echo "$B Paste github PUBLIC key, waiting 3s"
 sleep 2
 nano $HOME/.ssh/github.pub
 chmod 644 $HOME/.ssh/github.pub
fi

if ! grep -q "Host github.com" $HOME/.ssh/config; then
 echo "$B Paste github config to ~/.ssh/config, waiting 5s"
 echo "Host github.com"
 echo " User c0f"
 echo " IdentityFile = ~/.ssh/github"
 echo " Hostname ssh.github.com"
 echo " Port 443"
 echo "Host *"
 echo " AddKeysToAgent yes"
 sleep 5
 nano $HOME/.ssh/config
 chmod 644 $HOME/.ssh/config
fi

echo "$B Connecting to Github via ssh to add to known hosts"
ssh -T git@github.com

# git repo setup
if [ ! -f $HOME/.gitcfg/config ]; then
 echo "$B Creating new repo"
 git init --bare $HOME/.gitcfg
fi

if ! grep -q "alias gitc='$SETGIT --git-dir=$HOME/.gitcfg/ --work-tree=$HOME'" $HOME/.bashrc; then
 echo "$B Adding gitc alias to .bashrc"
 echo "alias gitc='$SETGIT --git-dir=$HOME/.gitcfg/ --work-tree=$HOME'" >> $HOME/.bashrc
fi

alias gitc='$SETGIT --git-dir=$HOME/.gitcfg/ --work-tree=$HOME'

if [ ! -d $HOME/.gitcfg ]; then
 echo ".gitcfg" >> $HOME/.gitignore
fi

echo "$B Settings"
gitc config --local status.showUntrackedFiles no
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=7200'
git config --global user.email "$SETGITEMAIL"
git config --global user.name "$SETGITNAME"
git config --global user.username c0f

echo "$B Remote will be ssh://git@github.com/c0f/$SETOS.git"
gitc remote add origin ssh://git@github.com/c0f/$SETOS.git

echo "$B Git Config"
gitc config --list | cat

echo "$B Git Remote Settings"
gitc remote -v

echo "$B Git Status"
gitc status

echo "$B Delete these files that might prevent first pull"
echo "rm .bashrc .bash_profile .gitignore .profile .Xdefaults .xscreensaver"
echo "rm .config/kateschemarc .config/kglobalshortcutsrc .config/kwinrc .config/konsolerc .config/gwenviewrc .config/katerc"
echo "rm .config/openbox/lxqt-rc.xml .config/pcmanfm-qt/lxqt/settings.conf .config/qterminal.org/qterminal.ini .config/lxterminal/lxterminal.conf"
echo "rm .config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml"

echo "$B Use this alias, then gitc clone"
echo "alias gitc='$SETGIT --git-dir=$HOME/.gitcfg/ --work-tree=$HOME'"
echo "gitc pull origin master"
echo " "
