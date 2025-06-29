#!/bin/bash

SUDO=''
if (($EUID != 0)); then
	SUDO='sudo'
fi

install_packages() {
	echo "Installing packages"
	$SUDO apt update
	$SUDO apt install -y git vim tmux zsh powerline fonts-powerline build-essential curl make gcc g++ clang zoxide ripgrep fd-find yarn lldb python3-pip python3-venv
	$SUDO apt install -y python3-dev docker.io cmake exuberant-ctags fzf ninja-build gettext unzip
    
    $SUDO add-apt-repository ppa:ondrej/php
	$SUDO apt install -y php8.4 php8.4-dev php8.4-gd php8.4-mbstring php8.4-xml php8.4-curl php8.4-mysql php8.4-fpm
}

download_configs() {
    if [ ! -d "~/ubuntu_settings_backup" ]; then
        echo "Start download configs from Helomair/ubuntu_settings_backup"
        git clone https://github.com/Helomair/ubuntu_settings_backup.git
    fi
}

setup_vim() {
    echo "Start setup vim"
    cp ~/ubuntu_settings_backup/.vimrc ~/.vimrc
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    vim --cmd 'source ~/.vimrc' -c 'qa!'
    vim --cmd 'PlugInstall' -c 'qa!'

    cd ~/.vim/bundle/YouCompleteMe
    python3 install.py
    cd ~
}

setup_neovim() {
    echo "Start setup neovim"

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
}

setup_tmux() {
    echo "Start setup tmux, using oh-my-tmux."
    git clone https://github.com/gpakosz/.tmux.git

    cp ~/ubuntu_settings_backup/.tmux.conf .tmux/.tmux.conf
    ln -s -f .tmux/.tmux.conf

    cp ~/ubuntu_settings_backup/.tmux.conf.local ~/.tmux.conf.local

    # TPM, tmux plugin manager
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

setup_composer() {
    echo "Start setup composer"
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php -r "if (hash_file('sha384', 'composer-setup.php') === 'dac665fdc30fdd8ec78b38b9800061b4150413ff2e3b6f88543c636f7cd84f6db9189d43a81e5503cda447da73c7e5b6') { echo 'Installer verified'.PHP_EOL; } else { echo 'Installer corrupt'.PHP_EOL; unlink('composer-setup.php'); exit(1); }"
    php composer-setup.php
    php -r "unlink('composer-setup.php');"
    sudo mv composer.phar /usr/local/bin/composer
}

setup_laravel() {
    echo "Start setup laravel."
    composer global require laravel/installer
    export PATH="$HOME/.config/composer/vendor/bin:$PATH"

    # Test Laravel Installer
    # if [ ! -d "~/mygit " ]; then
    #    echo "Dir mygit not found, make it."
    #    mkdir ~/mygit
    # fi
    # cd ~/mygit
    # laravel new laravel-test
}

setup_zsh() {
    echo "Start setup zsh, using oh-my-zsh."
    cp ~/ubuntu_settings_backup/.zshrc ~/.zshrc
    curl -Lo install.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
    sh install.sh
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
 
    exec /bin/zsh
}


declare -A PARAM_DESC=(
    ["--vim"]="Setup Vim with plugins and configurations"
    ["--tmux"]="Setup Tmux with oh-my-tmux and plugins"
    ["--neovim"]="Setup Neovim with nvimdots and configurations"
    ["--composer"]="Setup Composer globally"
    ["--laravel"]="Setup Laravel installer globally"
    ["--zsh"]="Setup Zsh with oh-my-zsh and plugins"
)

declare -A PARAM_FUNC=(
    ["--all"]="setup_vim setup_tmux setup_neovim setup_composer setup_laravel setup_zsh"
    ["--vim"]="setup_vim"
    ["--tmux"]="setup_tmux"
    ["--neovim"]="setup_neovim"
    ["--composer"]="setup_composer"
    ["--laravel"]="setup_laravel"
    ["--zsh"]="setup_zsh"
)

print_help() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    for key in "${!PARAM_DESC[@]}"; do
        printf "  %-4s  %s\n" "$key" "${PARAM_DESC[$key]}"
    done
    echo "  -h, --help  Display this help message"
    echo
    echo "If no arguments are provided, will exit with an error."
}

cd ~

# download_configs
# install_packages

if [ ${#selected_params[@]} -eq 0 ]; then
    echo "No valid parameters provided. Use --help for usage information."
    exit 1
fi

selected_params=()
while [ "$#" -gt 0 ]; do
    has_arguments=true
    case "$1" in
        -h|--help)
            print_help
            exit 0
            ;;
        --*)
            if [[ -n "${PARAM_FUNC[$1]}" ]]; then
                echo "Running setup for $1"
                selected_params+=("${PARAM_FUNC[$1]}")
            else
                echo "Unknown parameter: $1"
                print_help
                exit 1
            fi
            ;;
        *)
            echo "Unknown parameter: $1"
            echo "Usage: $0 [-a] [-b] [-c] [-d] [-e]"
            exit 1
            ;;
    esac
    shift
done



for key in "${selected_params[@]}"; do
    if declare -F "$key" > /dev/null; then
        echo "Executing $key"
        "$key"
    else
        echo "Function $key does not exist."
    fi
done


