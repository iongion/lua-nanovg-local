#!/bin/bash
set -e
PROJECT_HOME=$( dirname "$( cd "$( dirname "$0" )" && pwd )" )
function exit_error {
    printf "%s\n" "$*" >&2;
    exit -1;
}
L_EXT=so
if [[ ! -z $MINGW_PREFIX ]]; then
    L_EXT=dll
fi
cd $PROJECT_HOME
echo "Build project"
CI=true PROJECT_HOME=$PROJECT_HOME make -f Makefile
# resolving build tools
NVG_MAIN=$PROJECT_HOME/nvg.$L_EXT
echo "Checking if $NVG_MAIN exists"
if [[ ! -f $NVG_MAIN ]]; then
    exit_error "NanoVG build is missing from $NVG_MAIN"
fi
MOONGLFW_MAIN=$PROJECT_HOME/moonglfw.$L_EXT
echo "Checking if $MOONGLFW_MAIN exists"
if [[ ! -f $MOONGLFW_MAIN ]]; then
    exit_error "MoonGLFW build is missing from $MOONGLFW_MAIN"
fi
PATH=$HOME/.lua:$HOME/.luarocks/bin:$PATH
echo "Path altered - checking lua and luarocks PATH=$PATH"
echo "Running tests"
eval "$(luarocks path)"
lunit.sh -i $HOME/.lua/lua $PROJECT_HOME/test/test.lua
echo "Testing finished"
