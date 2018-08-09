#! /bin/bash
set -e
PROJECT_HOME=$( dirname "$( cd "$( dirname "$0" )" && pwd )" )
source $PROJECT_HOME/scripts/setup.sh
cd $PROJECT_HOME

echo "Ensuring luarocks $L_RK"

eval "$(luarocks path)"

echo "Installing rock: Lua-cURL"
luarocks --local install Lua-cURL --server=https://luarocks.org/dev

echo "Installing rock: luacov-coveralls"
luarocks --local install luacov-coveralls --server=https://luarocks.org/dev

echo "Installing rock: lunitx"
luarocks --local install lunitx
echo "Dependencies are now installed"

luarocks list
