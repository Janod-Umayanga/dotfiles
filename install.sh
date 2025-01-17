#!/bin/bash

PACKAGES = "alacritty i3 neofetch nvim picom polybar rofi tmux zsh stow"
DOTFILES_DIR = $(pwd)
TARGET_DIR = "$HOME"

install_packages() {
    echo "Installing packages..."
    if [ -x "$(command -v apt)" ]; then
        sudo apt update
        sudo apt install -y $PACKAGES
    elif [ -x "$(command -v pacman)" ]; then
        sudo pacman -Syu --noconfirm $PACKAGES
    elif [ -x "$(command -v brew)" ]; then
        brew install $PACKAGES
    else
        echo "Unsupported package manager. Please install the packages manually."
        exit 1
    fi
}

symlink_dotfiles() {
    echo "Symlinking configuration files using GNU stow..."
    if [ ! -d "$DOTFILES_DIR" ]; then
        echo "Dotfiles directory not found at $DOTFILES_DIR"
        exit 1
    fi

    cd "$DOTFILES_DIR" || exit
    for dir in $(ls -d */); do
	package_name="${dir%/}"
	echo "Symlinking $package_name to $TARGET_DIR"
    	stow -t "$TARGET_DIR" "$package_name"
    done
    echo "Dotfiles successfully symlinked!"
}

check_package_installed() {
    command -v "$1" >/dev/null 2>&1
}

# Main script
echo "Starting setup process..."
install_packages
symlink_dotfiles

# set Zsh as default shell
if check_package_installed zsh; then
    echo "Setting Zsh as default shell..."
    chsh -s "$(command -v zsh)"
else
    echo "Zsh not found. Skipping shell configuration."
fi

echo "Setup completed!"
