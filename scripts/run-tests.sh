#! /bin/bash
set -e
PROJECT_HOME=$( dirname "$( cd "$( dirname "$0" )" && pwd )" )
source $PROJECT_HOME/scripts/setup.sh
cd $PROJECT_HOME
echo "Running tests"
# start x
MY_CI="${CI:-}"
if [[ ! -z "${MY_CI}" ]]; then
    if [[ "${machine}" == "Linux" ]]; then
        echo "Starting X virtual framebuffer server"
        sudo Xvfb :100 -screen 0 1600x1200x16 &
        export DISPLAY=:100
        # Wait for Xvfb
        MAX_ATTEMPTS=120
        COUNT=0
        echo -n "Waiting for Xvfb to be ready..."
        while ! xdpyinfo -display $DISPLAY >/dev/null 2>&1; do
            echo -n "."
            sleep 0.50s
            COUNT=$(( COUNT + 1 ))
            if [ "${COUNT}" -ge "${MAX_ATTEMPTS}" ]; then
                echo "  Gave up waiting for X server on $DISPLAY"
                exit 1
            fi
        done
    fi
fi
# test
eval "$(luarocks path)"
echo "Testing PATH=$PATH"
$HOME/.luarocks/bin/lunit.sh -i `which lua5.3` $PROJECT_HOME/test/test.lua
echo "Testing finished"
