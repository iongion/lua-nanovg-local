#! /bin/bash
set -e
PROJECT_HOME=$( dirname "$( cd "$( dirname "$0" )" && pwd )" )
source $PROJECT_HOME/scripts/setup.sh
cd $PROJECT_HOME

echo "Ensuring lua rocks home directory in $LR_HOME_DIR"
mkdir -p "$LR_HOME_DIR"
LUARKSRC_BAS=luarocks-$L_RK
LUARKSRC_TGZ=$LUARKSRC_BAS.tar.gz
LUARKSRC_PKG="http://luarocks.github.io/luarocks/releases/$LUARKSRC_TGZ"
echo "Switching to $T_BD"
cd $T_BD
if [[ ! -f $LUARKSRC_TGZ ]]; then
    echo "Downloading $LUARKSRC_BAS from $LUARKSRC_PKG to $LUARKSRC_TGZ"
    curl --location $LUARKSRC_PKG -o $LUARKSRC_TGZ
fi
if [[ -f $LUARKSRC_TGZ ]] && [[ ! -d $LUARKSRC_BAS ]]; then
    tar zxf $LUARKSRC_TGZ
fi
if [[ ! -d $LUARKSRC_BAS ]]; then
    exit_error "Lua rocks source directory is not accessible"
fi
echo "Switching to $T_BD/$LUARKSRC_BAS"
cd $T_BD/$LUARKSRC_BAS
ROCKS_PATH=$T_BD/install/.luarocks
if [[ ! -f $T_BD/install/luarocks/bin/luarocks ]]; then
    mkdir -p $T_BD/install/.luarocks
    if [[ -f Makefile ]]; then
        make clean
    fi
    ./configure --with-lua="$LUA_HOME_DIR" \
        --prefix="$T_BD/install/luarocks" \
        --sysconfdir="$T_BD/install/etc/luarocks" \
        --rocks-tree="$ROCKS_PATH"
   make build && make install
fi
PATH=$T_BD/install/lua/bin:$T_BD/install/luarocks/bin:$T_BD/install/.luarocks/bin:$PATH
eval "$($T_BD/install/luarocks/bin/luarocks path)"
if [[ ! -d $ROCKS_PATH/share/lua/$L_LU/cURL ]]; then
    echo "Installing rock: Lua-cURL"
    luarocks --project-tree=$ROCKS_PATH install Lua-cURL --server=https://luarocks.org/dev
else
    echo "Rock installed: Lua-cURL"
fi
if [[ ! -d $ROCKS_PATH/share/lua/$L_LU/luacov ]]; then
    echo "Installing rock: luacov-coveralls"
    luarocks --project-tree=$ROCKS_PATH install luacov-coveralls --server=https://luarocks.org/dev
else
    echo "Rock installed: luacov-coveralls"
fi
if [[ ! -d $ROCKS_PATH/share/lua/$L_LU/lunitx ]]; then
    echo "Installing rock: lunitx"
    luarocks --project-tree=$ROCKS_PATH install lunitx
    echo "Dependencies are now installed"
else
    echo "Rock installed: lunitx"
fi
luarocks list
