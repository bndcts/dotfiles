#!/usr/bin/env bash

########################################
# Dotfiles directory
########################################

# DOTFILES = directory of this script (assumes script is run from within the cloned repo)
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

########################################
# XDG paths
########################################

XDG_CACHE_HOME="$HOME/.cache"
XDG_CONFIG_HOME="${HOME}/.config"
XDG_DATA_HOME="${HOME}/.local/share"
XDG_STATE_HOME="${HOME}/.local/state"

mkdir -p "$XDG_CACHE_HOME" "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME"

########################################
# Helper functions
########################################

title() {
  printf "\n\033[1m%s\033[0m\n" "$*"
}

info() {
  printf "[INFO] %s\n" "$*"
}

warning() {
  printf "[WARN] %s\n" "$*"
}

########################################
# Linking dotfiles
########################################

link_config_files () {
    linkDotfile tmux
    linkDotfile lazygit
    linkDotfile git
}

linkDotfile () {
  dest="${HOME}/.config/${1}"
  dotfilesDir="$DOTFILES/config"
  source="${dotfilesDir}/${1}"

  # Check if source exists
  if [ ! -e "${source}" ]; then
    warning "Source ${source} does not exist. Skipping."
    return
  fi

  # Check if symlink already exists and points to the correct location
  if [ -h "${dest}" ]; then
    current_target="$(readlink "${dest}")"
    expected_target="${source}"
    if [ "$current_target" = "$expected_target" ]; then
      info "Symlink ${dest} already points to correct location. Skipping."
      return
    else
      echo "Removing existing symlink pointing to wrong location: ${dest}"
      rm "${dest}"
    fi
  elif [ -f "${dest}" ] || [ -d "${dest}" ]; then
    echo "Backing up existing file/dir: ${dest} into ${XDG_DATA_HOME}/backup"
    mkdir -p "${XDG_DATA_HOME}/backup" && mv "${dest}" "${XDG_DATA_HOME}/backup"
  fi

  echo "Creating new symlink: ${dest} -> ${source}"
  ln -s "${source}" "${dest}"
}


########################################
# Git setup
########################################

setup_git() {
    defaultName=$(git config user.name)
    defaultEmail=$(git config user.email)
    defaultGithub=$(git config github.user)

    read -rp "Name [$defaultName] " name
    read -rp "Email [$defaultEmail] " email
    read -rp "Github username [$defaultGithub] " github

    git config -f ~/.gitconfig-local user.name "${name:-$defaultName}"
    git config -f ~/.gitconfig-local user.email "${email:-$defaultEmail}"
    git config -f ~/.gitconfig-local github.user "${github:-$defaultGithub}"
}

########################################
# Shell / Zsh / Vim
########################################

link_zshrc() {
    local source_file="$DOTFILES/.zshrc"
    local destination_file="$HOME/.zshrc"
    local backup_dir="$XDG_DATA_HOME/backup"

    # Check if source exists
    if [ ! -f "$source_file" ]; then
        warning "Source $source_file does not exist. Skipping."
        return
    fi

    # Check if symlink already exists and points to the correct location
    if [ -h "$destination_file" ]; then
        current_target="$(readlink "$destination_file")"
        expected_target="$source_file"
        if [ "$current_target" = "$expected_target" ]; then
            info "Symlink $destination_file already points to correct location. Skipping."
            return
        else
            echo "Removing existing symlink pointing to wrong location: $destination_file"
            rm "$destination_file"
        fi
    elif [ -f "$destination_file" ]; then
        echo "Backing up existing ~/.zshrc to $backup_dir"
        mkdir -p "$backup_dir" && mv "$destination_file" "$backup_dir/"
    fi

    echo "Creating symlink for ~/.zshrc"
    ln -s "$source_file" "$destination_file"
}

link_vim() {
    local backup_dir="$XDG_DATA_HOME/backup"
    mkdir -p "$backup_dir"

    # Handle .vimrc
    local vimrc_source="$DOTFILES/.vimrc"
    local vimrc_dest="$HOME/.vimrc"
    
    if [ -f "$vimrc_source" ]; then
        if [ -h "$vimrc_dest" ]; then
            current_target="$(readlink "$vimrc_dest")"
            if [ "$current_target" = "$vimrc_source" ]; then
                info "Symlink $vimrc_dest already points to correct location. Skipping."
            else
                echo "Removing existing symlink pointing to wrong location: $vimrc_dest"
                rm "$vimrc_dest"
                echo "Creating symlink for ~/.vimrc"
                ln -s "$vimrc_source" "$vimrc_dest"
            fi
        elif [ -f "$vimrc_dest" ]; then
            echo "Backing up existing ~/.vimrc to $backup_dir"
            mv "$vimrc_dest" "$backup_dir/"
            echo "Creating symlink for ~/.vimrc"
            ln -s "$vimrc_source" "$vimrc_dest"
        else
            echo "Creating symlink for ~/.vimrc"
            ln -s "$vimrc_source" "$vimrc_dest"
        fi
    else
        warning "Source $vimrc_source does not exist. Skipping .vimrc."
    fi

    # Handle .vim
    local vim_source="$DOTFILES/.vim"
    local vim_dest="$HOME/.vim"
    
    if [ -d "$vim_source" ]; then
        if [ -h "$vim_dest" ]; then
            current_target="$(readlink "$vim_dest")"
            if [ "$current_target" = "$vim_source" ]; then
                info "Symlink $vim_dest already points to correct location. Skipping."
            else
                echo "Removing existing symlink pointing to wrong location: $vim_dest"
                rm "$vim_dest"
                echo "Creating symlink for ~/.vim"
                ln -s "$vim_source" "$vim_dest"
            fi
        elif [ -d "$vim_dest" ]; then
            echo "Backing up existing ~/.vim to $backup_dir"
            mv "$vim_dest" "$backup_dir/"
            echo "Creating symlink for ~/.vim"
            ln -s "$vim_source" "$vim_dest"
        else
            echo "Creating symlink for ~/.vim"
            ln -s "$vim_source" "$vim_dest"
        fi
    else
        warning "Source $vim_source does not exist. Skipping .vim."
    fi
}

setup_shell() {
    # Clone oh-my-zsh if it doesn't exist
    if [ ! -d "$XDG_DATA_HOME/oh-my-zsh" ]; then
        info "Cloning oh-my-zsh..."
        git clone https://github.com/ohmyzsh/ohmyzsh.git "$XDG_DATA_HOME/oh-my-zsh"
    else
        info "oh-my-zsh already exists. Skipping clone."
    fi

    link_zshrc

    mkdir -p "$XDG_DATA_HOME/oh-my-zsh/custom/plugins"

    # Clone zsh-autosuggestions if it doesn't exist
    if [ ! -d "$XDG_DATA_HOME/oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
        info "Cloning zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions \
          "$XDG_DATA_HOME/oh-my-zsh/custom/plugins/zsh-autosuggestions"
    else
        info "zsh-autosuggestions already exists. Skipping clone."
    fi

    # Clone zsh-syntax-highlighting if it doesn't exist
    if [ ! -d "$XDG_DATA_HOME/oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
        info "Cloning zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
          "$XDG_DATA_HOME/oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
    else
        info "zsh-syntax-highlighting already exists. Skipping clone."
    fi

    # catppuccin syntax highlighting theme
    if [ ! -d "$XDG_DATA_HOME/catpuccin/syntax-hightlighting" ]; then
        info "Cloning catppuccin syntax highlighting..."
        git clone https://github.com/catppuccin/zsh-syntax-highlighting.git \
          "$XDG_DATA_HOME/catpuccin/syntax-hightlighting"
    else
        info "catppuccin syntax highlighting already exists. Skipping clone."
    fi
}


setup_macos() {
    title "Configuring macOS"
    if [[ "$(uname)" == "Darwin" ]]; then

        echo "Finder: show all filename extensions"
        defaults write NSGlobalDomain AppleShowAllExtensions -bool true

        echo "show hidden files by default"
        defaults write com.apple.Finder AppleShowAllFiles -bool false

        echo "only use UTF-8 in Terminal.app"
        defaults write com.apple.terminal StringEncodings -array 4

        echo "expand save dialog by default"
        defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

        echo "show the ~/Library folder in Finder"
        chflags nohidden ~/Library

        echo "Enable full keyboard access for all controls"
        defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

        echo "Enable subpixel font rendering on non-Apple LCDs"
        defaults write NSGlobalDomain AppleFontSmoothing -int 2

        echo "Use current directory as default search scope in Finder"
        defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

        echo "Show Path bar in Finder"
        defaults write com.apple.finder ShowPathbar -bool true

        echo "Show Status bar in Finder"
        defaults write com.apple.finder ShowStatusBar -bool true

        echo "Set standard finder view to list"
        defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

        echo "Set a blazingly fast keyboard repeat rate"
        defaults write NSGlobalDomain KeyRepeat -int 1

        echo "Set a shorter Delay until key repeat"
        defaults write NSGlobalDomain InitialKeyRepeat -int 15

        echo "Kill affected applications"
        for app in Safari Finder Dock Mail SystemUIServer; do
          killall "$app" >/dev/null 2>&1 || true
        done
    else
        warning "macOS not detected. Skipping."
    fi
}

########################################
# Homebrew
########################################

setup_homebrew() {
    if ! command -v brew >/dev/null 2>&1; then
        info "Homebrew not installed. Installing."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    if [ "$(uname)" == "Linux" ]; then
        echo "This is linux, TODO"
    fi

    if [ -f "$DOTFILES/Brewfile" ]; then
        info "Brewfile found. Running brew bundle."
        brew bundle --file="$DOTFILES/Brewfile"
    else
        info "No Brewfile found, skipping brew bundle."
    fi

}

########################################
# Entry point / CLI
########################################

case "$1" in
    shell)
        setup_shell
        ;;
    macos)
        setup_macos
        ;;
    homebrew)
        setup_homebrew
        ;;
    link)
        link_config_files
        ;;
    git)
        setup_git
        ;;
    all-mac)
        setup_homebrew
        setup_shell
        setup_macos
        link_vim
        link_config_files
        ;;
    *)
        echo -e "\nUsage: $(basename "$0") {link|git|homebrew|shell|macos|all-mac}\n"
        exit 1
        ;;
esac

