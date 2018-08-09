#! /bin/bash
set -e
PROJECT_HOME=$( dirname "$( cd "$( dirname "$0" )" && pwd )" )
source $PROJECT_HOME/scripts/setup.sh
cd $PROJECT_HOME

echo "Ensuring lua home directory in $LUA_HOME_DIR"
mkdir -p "$LUA_HOME_DIR"
# Lua 5.x
LUASRC_BASE=5.3.5
if [ "$L_LU" == "5.1" ]; then
LUASRC_BASE=5.1.5
elif [ "$L_LU" == "5.2" ]; then
LUASRC_BASE=5.2.4
elif [ "$L_LU" == "5.3" ]; then
LUASRC_BASE=5.3.5
fi
LUASRC_BAS=lua-$LUASRC_BASE.tar.gz
LUASRC_PKG="https://www.lua.org/ftp/$LUASRC_BAS"
LUASRC_TGZ=$T_BD/$LUASRC_BAS
echo "Switching to $T_BD"
cd $T_BD
if [[ ! -f $LUASRC_TGZ ]]; then
    echo "Downloading $LUASRC_BASE from $LUASRC_PKG to $LUASRC_TGZ"
    curl --location $LUASRC_PKG -o $LUASRC_TGZ
fi
if [[ -f $LUASRC_TGZ ]] && [[ ! -d lua-$LUASRC_BASE ]]; then
    tar zxf $LUASRC_BAS
fi
if [[ ! -d lua-$LUASRC_BASE ]]; then
    exit_error "Lua source directory is not accessible"
fi
echo "Switching to $T_BD/lua-$LUASRC_BASE"
cd $T_BD/lua-$LUASRC_BASE
if [[ ! -f src/lua$E_EXT ]]; then
    # Build Lua without backwards compatibility for testing
    perl -i -pe 's/-DLUA_COMPAT_(ALL|5_2)//' src/Makefile
    make $PLATFORM clean
    make $PLATFORM MYCFLAGS=-fPIC && make INSTALL_TOP="$LUA_HOME_DIR" install;
else
    echo "Lua executable already found in $T_BD/lua-$LUASRC_BASE/src/lua$E_EXT"
fi
