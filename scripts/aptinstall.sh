#!/bin/bash

apt update

function install {
  which $1 &> /dev/null

  if [ $? -ne 0 ]; then
    echo "Installing: ${1}..."
    apt install -y $1
  else
    echo "Already installed: ${1}"
  fi
}

# Basics
install tmux
install vim

# oh my zsh
sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

# Fun stuff
#install figlet
#install lolcat
