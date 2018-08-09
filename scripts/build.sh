#! /bin/bash
set -e
PROJECT_HOME=$( dirname "$( cd "$( dirname "$0" )" && pwd )" )
source $PROJECT_HOME/scripts/setup.sh
cd $PROJECT_HOME

if [[ -f $T_BD/install/lua/bin ]]; then
    eval "$($T_BD/install/luarocks/bin/luarocks path)"
    PATH=$T_BD/install/lua/bin:$T_BD/install/luarocks/bin:$T_BD/install/.luarocks/bin:$PATH
fi

if [[ ! -z "${CI}" ]]; then
    CI=true
fi

echo "Building project starting"
PREFIX=$T_BD/install/.luarocks make clean
PREFIX=$T_BD/install/.luarocks make install
echo "Building project finished"
