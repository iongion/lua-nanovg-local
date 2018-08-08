#! /bin/bash
set -e
PROJECT_HOME=$( dirname "$( cd "$( dirname "$0" )" && pwd )" )
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=OSX;;
    CYGWIN*)    machine=Windows;;
    MINGW*)     machine=Windows;;
    *)          machine="UNKNOWN:${unameOut}"
esac

if [[ "${machine}" == "Linux" ]]; then
    sudo apt-get install -y libglfw3-dev
fi

# Homebrew
if [[ "${machine}" == "OSX" ]]; then
    brew install glfw
fi

if [[ "${machine}" == "Windows" ]]; then
    pacman -S --noconfirm mingw-w64-x86_64-glfw
fi
