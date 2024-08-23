#!/usr/bin/env bash

DOTFILES="$(pwd)"

# Default XDG paths
XDG_CACHE_HOME="$HOME/.cache"
XDG_CONFIG_HOME="${HOME}/.config"
XDG_DATA_HOME="${HOME}/.local/share"
XDG_STATE_HOME="${HOME}/.local/state"

mkdir -p "$XDG_CACHE_HOME"
mkdir -p "$XDG_CONFIG_HOME"
mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_STATE_HOME"

link_config_files () {
    linkDotfile tmux
    #linkDotfile nvim
    linkDotfile lazygit
    linkDotfile git
    linkDotfile wezterm
}


linkDotfile () {
  dest="${HOME}/.config/${1}"
  dotfilesDir="$DOTFILES/config"
  if [ -h "{$dest}" ]; then
    # Existing symlink
    echo "Removing existing symlink: ${dest}"
    rm ${dest}

  elif [ -f "${dest}" ]; then
    # Existing file
    echo "Backing up existing file: ${dest} into ${XDG_DATA_HOME}"
    mkdir -p "${XDG_DATA_HOME}/backup" && mv "${dest}" "${XDG_DATA_HOME}/backup"

  elif [ -d "${dest}" ]; then
    # Existing dir
    echo "Backing up existing dir: ${dest} into ${XDG_DATA_HOME}"
    mkdir -p "${XDG_DATA_HOME}/backup" && mv "${dest}" "${XDG_DATA_HOME}/backup"
  fi

  echo "Creating new symlink: ${dest}"
  ln -s ${dotfilesDir}/${1} ${dest}
}

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

link_zshrc() {
    source_file="$DOTFILES/.zshrc"
    destination_file="$HOME/.zshrc"

    backup_dir="$XDG_DATA_HOME/backup"

    if [ -f "$destination_file" ]; then
        echo "Backing up existing ~/.zshrc to $backup_dir"
        mkdir -p "$backup_dir" && mv "$destination_file" "$backup_dir/"
    fi

    # Create symlink
    echo "Creating symlink for ~/.zshrc"
    ln -s "$source_file" "$destination_file"
}

link_vim() {
    mkdir -p $XDG_DATA_HOME/backup && [ ! -f ~/.vimrc ] || mv ~/.vimrc $XDG_DATA_HOME/backup
    mkdir -p $XDG_DATA_HOME/backup && [ ! -f ~/.vim ] || mv ~/.vim $XDG_DATA_HOME/backup
    ln -s $DOTFILES/.vimrc ~/
    ln -s $DOTFILES/.vim ~/
}

setup_shell() {
    git clone https://github.com/ohmyzsh/ohmyzsh.git $XDG_DATA_HOME/oh-my-zsh
    link_zshrc
   git clone https://github.com/zsh-users/zsh-autosuggestions ~/.local/share/oh-my-zsh/custom/plugins/zsh-autosuggestions
   git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.local/share/oh-my-zsh/custom/plugins/zsh-syntax-highlighting

   ## catppuccin theme
   git clone https://github.com/catppuccin/zsh-syntax-highlighting.git $XDG_DATA_HOME/catpuccin/syntax-hightlighting

}

setup_macos() {
    title "Configuring macOS"
    if [[ "$(uname)" == "Darwin" ]]; then

        echo "Finder: show all filename extensions"
        defaults write NSGlobalDomain AppleShowAllExtensions -bool true

        echo "shw hidden files by default"
        defaults write com.apple.Finder AppleShowAllFiles -bool false

        echo "only use UTF-8 in Terminal.app"
        defaults write com.apple.terminal StringEncodings -array 4

        echo "expand save dialog by default"
        defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

        echo "show the ~/Library folder in Finder"
        chflags nohidden ~/Library

        echo "Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)"
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

        for app in Safari Finder Dock Mail SystemUIServer; do killall "$app" >/dev/null 2>&1; done
    else
        warning "macOS not detected. Skipping."
    fi
}

setup_homebrew() {
    if test ! "$(command -v brew)"; then
        info "Homebrew not installed. Installing."
        # Run as a login shell (non-interactive) so that the script doesn't pause for user input
        curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash --login
    fi

    if [ "$(uname)" == "Linux" ]; then
	echo "This is linux, TODO"
    fi

    # install brew dependencies from Brewfile
    brew bundle
}

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
        setup_shell
        setup_macos
        link_vim
        link_config_files
        ;;
    *)
        echo -e $"\nUsage: $(basename "$0") {backup|link|git|homebrew|shell|terminfo|macos|all}\n"
        exit 1
        ;;
esac


