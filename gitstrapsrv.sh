#!/bin/sh
# Banner
B=[][][][]

REPO=srv

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
 sleep 10
 nano $HOME/.ssh/config
 chmod 644 $HOME/.ssh/config
fi

echo "$B Connecting to Github via ssh to add to known hosts"
ssh -T git@github.com

# git repo setup
if [ ! -f $HOME/.gitcfg/config ]; then
 echo "$B Creating new local repo"
 git init --bare $HOME/.gitcfg
fi

if ! grep -q "alias gitc='$SETGIT --git-dir=$HOME/.gitcfg/ --work-tree=$HOME'" $HOME/.bashrc; then
 echo "$B Adding gitc alias to .bashrc"
 echo "alias gitc='git --git-dir=$HOME/.gitcfg/ --work-tree=$HOME'" >> $HOME/.bashrc
fi

alias gitc='$SETGIT --git-dir=$HOME/.gitcfg/ --work-tree=$HOME'

if [ ! -d $HOME/.gitcfg ]; then
 echo ".gitcfg" >> $HOME/.gitignore
fi

echo "$B Installing"
sudo apt -y install fail2ban auditd msmtp msmtp-mta s-nail

echo "$B Settings"
GITEMAIL=bod@o9.org
GITNAME="$USER@$HOSTNAME"
GITUSERNAME=bod
echo "$B Git Name: $GITNAME  /  Email: $GITEMAIL  /  Username: $GITUSERNAME"
gitc config --local status.showUntrackedFiles no
gitc config --local user.email "$GITEMAIL"
gitc config --local user.name "$GITNAME" # This is displayed as the 'Author' in commits
gitc config --local user.username "$GITUSERNAME"
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=7200'
git config --global user.email "$GITEMAIL"
git config --global user.name "$GITNAME" # This is displayed as the 'Author' in commits
git config --global user.username "$GITUSERNAME"

echo "$B Remote will be ssh://git@github.com/c0f/$REPO.git"
gitc remote add origin ssh://git@github.com/c0f/$REPO.git

echo "$B Git Config"
gitc config --list | cat

echo "$B Git Remote Settings"
gitc remote -v

echo "$B Git Status"
gitc status

echo "$B Run these commands for initial pull."
echo "rm .bashrc .bash_profile .gitignore .profile"
echo "alias gitc='$SETGIT --git-dir=$HOME/.gitcfg/ --work-tree=$HOME'"
echo "gitc pull origin main"
echo " "
