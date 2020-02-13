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
$SUDO apt install git vim tmux zsh powerline fonts-powerline build-essential python3-dev php curl

# Move to HOME
cd ~

# If configs not download yet, download them.
if [ ! -d "~/ubuntu_settings_backup" ]; then
    echo "Start download configs from Helomair/ubuntu_settings_backup"
    git clone https://github.com/Helomair/ubuntu_settings_backup.git
fi

# Copy configs to HOME
cp -a ~/ubuntu_settings_backup/. ~

# Setup vim
echo "Start setup vim"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# For vim Plugin tagbar
$SUDO apt install exuberant-ctags

$SUDO vim +PlugInstall +qall

echo "Start setup tmux, using oh-my-tmux."
git clone https://github.com/gpakosz/.tmux.git
ln -s -f .tmux/.tmux.conf

echo "Start setup zsh, using oh-my-zsh."
$SUDO sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
if [ -f "~/.zshrc.pre-oh-my-zsh" ]; then
    rm .zshrc
    mv .zshrc.pre-oh-my-zsh .zshrc
fi
