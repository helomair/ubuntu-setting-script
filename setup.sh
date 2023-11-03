#!/bin/bash
# Program:
#       Ubuntu setup.
# Auther:
#       Helomair
# 2020-2-7

SUDO=''
if (($EUID != 0)); then
	SUDO='sudo'
fi

# Install packages
echo "Installing packages"
$SUDO apt update
$SUDO apt install -y git vim tmux zsh powerline fonts-powerline build-essential curl make gcc g++ clang zoxide ripgrep fd-find yarn lldb python3-pip python3-venv
$SUDO apt install -y python3-dev docker.io cmake exuberant-ctags fzf ninja-build gettext unzip
$SUDO apt install -y php8.1 php8.1-dev php8.1-gd php8.1-mbstring php8.1-xml php8.1-curl php8.1-mysql php8.1-fpm

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
vim --cmd 'source ~/.vimrc' -c 'qa!'
vim --cmd 'PlugInstall' -c 'qa!'

# Compile Plugin YouCompleteMe
cd ~/.vim/bundle/YouCompleteMe
./install.sh --clang-completer

cd ~

# Setup neovim
## nvim appimage
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
ln -s ~/nvim.appimage /usr/bin/nvim

## bob, nvim version manager
curl https://sh.rustup.rs -sSf | sh
source "$HOME/.cargo/env"
cargo install --git https://github.com/MordechaiHadad/bob.git
bob install nightly
bob use nightly

### nvimdots, nvim configuration
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
### nvm
curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
nvm install 18
nvm use 18

if command -v curl >/dev/null 2>&1; then
	bash -c "$(curl -fsSL https://raw.githubusercontent.com/ayamir/nvimdots/HEAD/scripts/install.sh)"
else
	bash -c "$(wget -O- https://raw.githubusercontent.com/ayamir/nvimdots/HEAD/scripts/install.sh)"
fi

yes | cp -rf ~/ubuntu_settings_backup/nvimdots_user_settings_backup/* .config/nvim/lua/user

# Setup Oh-My-Tmux
echo "Start setup tmux, using oh-my-tmux."
git clone https://github.com/gpakosz/.tmux.git
cp ~/ubuntu_settings_backup/.tmux.conf .tmux/.tmux.conf
ln -s -f .tmux/.tmux.conf
cp ~/ubuntu_settings_backup/.tmux.conf.local ~/.tmux.conf.local

# Setup Composer & Laravel
#echo "Start setup composer & laravel."
# Install Composer
#php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
#php -r "if (hash_file('sha384', 'composer-setup.php') === 'e0012edf3e80b6978849f5eff0d4b4e4c79ff1609dd1e613307e16318854d24ae64f26d17af3ef0bf7cfb710ca74755a') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
#php composer-setup.php
#php -r "unlink('composer-setup.php');"

# Require Laravel Intaller
#composer global require laravel/installer
#export PATH="$HOME/.config/composer/vendor/bin:$PATH"

# Test Laravel Installer
#if [ ! -d "~/mygit " ]; then
#    echo "Dir mygit not found, make it."
#    mkdir ~/mygit
#fi
#cd ~/mygit
#laravel new laravel-test

# Setup Zsh
echo "Start setup zsh, using oh-my-zsh."
curl -Lo install.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
sh install.sh
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

cp ~/ubuntu_settings_backup/.zshrc ~/.zshrc
# source ~/.zshrc
exec /bin/zsh
