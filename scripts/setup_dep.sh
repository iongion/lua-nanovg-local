#!/bin/bash
set -e
PROJECT_HOME=$( dirname "$( cd "$( dirname "$0" )" && pwd )" )
source $PROJECT_HOME/scripts/setup.sh
cd $PROJECT_HOME

echo "Resolving dependencies"

if [[ "${machine}" == "Linux" ]]; then
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt-get install -y \
        asciidoctor \
        ruby-pygments.rb \
        libglfw3-dev \
        xvfb \
        libgl1-mesa-dev \
        libosmesa6-dev \
        libgles2-mesa-dev \
        libgles2-mesa-dev \
        libgles2-mesa-dev \
        mesa-utils \
        mesa-utils-extra \
        libreadline-dev \
        unzip \
        curl \
        libcurl3-gnutls-dev
fi

# Homebrew
if [[ "${machine}" == "OSX" ]]; then
    brew install glfw
fi

if [[ "${machine}" == "Windows" ]]; then
    pacman -S --noconfirm mingw-w64-x86_64-glfw \
        mingw64/mingw-w64-x86_64-glew \
        mingw64/mingw-w64-x86_64-mesa \
        mingw64/mingw-w64-x86_64-asciidoctor
fi
