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
$SUDO apt update
$SUDO apt install -y git vim tmux zsh powerline fonts-powerline build-essential 
$SUDO apt install -y python3-dev curl docker.io cmake exuberant-ctags fzf
$SUDO apt install -y php7.3 php7.3-dev php7.3-gd php7.3-mbstring php7.3-xml php7.3-curl php7.3-mysql

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

cd ~

# Setup Oh-My-Tmux
echo "Start setup tmux, using oh-my-tmux."
git clone https://github.com/gpakosz/.tmux.git
ln -s -f .tmux/.tmux.conf
cp ~/ubuntu_settings_backup/.tmux.conf.local ~/.tmux.conf.local


# Setup Composer & Laravel
echo "Start setup composer & laravel."
# Install Composer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === 'e0012edf3e80b6978849f5eff0d4b4e4c79ff1609dd1e613307e16318854d24ae64f26d17af3ef0bf7cfb710ca74755a') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"

# Require Laravel Intaller
composer global require laravel/installer
export PATH="$HOME/.config/composer/vendor/bin:$PATH"

# Test Laravel Installer
if [ ! -d "~/mygit " ]; then
    echo "Dir mygit not found, make it."
    mkdir ~/mygit 
fi
cd ~/mygit
laravel new laravel-test

# Setup Zsh
echo "Start setup zsh, using oh-my-zsh."
curl -Lo install.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
sh install.sh

cp ~/ubuntu_settings_backup/.zshrc ~/.zshrc 
source ~/.zshrc 
exec /bin/zsh
