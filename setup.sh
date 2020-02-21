#!/bin/bash
# Program:
#       Ubuntu setup.
# Auther:
#       Helomair
# 2020-2-7

SUDO=''
if (( $EUID != 0 )); then
    SUDO='sudo'
fi

# Install packages
echo "Installing packages"
$SUDO apt install -y git 
$SUDO apt install -y vim
$SUDO apt install -y tmux 
$SUDO apt install -y zsh
$SUDO apt install -y powerline
$SUDO apt install -y fonts-powerline
$SUDO apt install -y build-essential
$SUDO apt install -y python3-dev
$SUDO apt install -y php
$SUDO apt install -y curl
$SUDO apt install -y docker
$SUDO apt install -y cmake
$SUDO apt install -y exuberant-ctags
# $SUDO apt install fzf

# Move to HOME
cd ~

# If configs not download yet, download them.
if [ ! -d "~/ubuntu_settings_backup" ]; then
    echo "Start download configs from Helomair/ubuntu_settings_backup"
    git clone https://github.com/Helomair/ubuntu_settings_backup.git
fi

# Setup vim
echo "Start setup vim"
cp ~/ubuntu_settings_backup/.vimrc ~/.vimrc
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim 
$SUDO vim +PlugInstall +qall

# Compile Plugin YouCompleteMe 
cd ~/.vim/bundle/YouCompleteMe 
./install.sh --clang-completer

echo "Start setup tmux, using oh-my-tmux."
cp ~/ubuntu_settings_backup/.tmux.conf.local ~/.tmux.conf.local
git clone https://github.com/gpakosz/.tmux.git
ln -s -f .tmux/.tmux.conf

echo "Start setup zsh, using oh-my-zsh."
$SUDO sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

exec /bin/zsh

cp ~/ubuntu_settings_backup/.zshrc ~/.zshrc 
source ~/.zshrc 
