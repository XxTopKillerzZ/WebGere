#!/bin/bash

echo -e "\e[32mAutomatic FXServer Setup Script for Ubuntu 18.04 LTS...\e[39m"
echo
echo -e "\e[32mAuthor: WebGere\e[39m"
echo -e "\e[32mWebsite: https://webgere.pt\e[39m"
echo
echo -e "\e[32mCurrent Version: v0.1\e[39m"
echo
echo

echo -e "\e[32mInstalling Dependencies...\e[39m"
apt-get -y update
if command -v sudo >/dev/null 2>&1 ; then
    echo -e "\e[32mSudo Found...\e[39m"
else
    echo -e "\e[32mInstalling Sudo...\e[39m"
    apt-get install -y sudo
fi
if command -v wget >/dev/null 2>&1 ; then
    echo -e "\e[32mWet Found...\e[39m"
else
    echo -e "\e[32mInstalling Wget...\e[39m"
    sudo apt-get install -y wget
fi
if command -v tar >/dev/null 2>&1 ; then
    echo -e "\e[32mTar Found...\e[39m"
else
    echo -e "\e[32mInstalling Tar...\e[39m"
    sudo apt-get install -y tar
fi


echo -e "\e[32mCreating Directories...\e[39m"
if [ ! -d "$HOME/fivem" ]; then
    mkdir "$HOME/fivem"
    echo Created base directory
else
    echo Skipping base directory, already exists
fi
if [ ! -d "$HOME/fivem/temp" ]; then
    mkdir "$HOME/fivem/temp"
    echo Created temp directory
else
    echo Skipping temp directory, already exists
fi
if [ ! -d "$HOME/fivem/server" ]; then
    mkdir "$HOME/fivem/server"
    echo Created server directory
else
    echo Skipping server directory, already exists
fi
if [ ! -d "$HOME/fivem/server-data" ]; then
    mkdir "$HOME/fivem/server-data"
    echo Created server-data directory
else
    echo Skipping server-data directory, already exists
fi
echo -e "\e[32mDone creating directories.\e[39m"

echo -e "\e[32mWhat Version do you want to install.\e[39m"
read VERSION_WANTED
echo -e "\e[32mUsing $VERSION_WANTED...\e[39m"


if [ ! -f "$HOME/fivem/server/version_wanted.log" ]; then
    touch "$HOME/fivem/server/version_wanted.log"
fi
if [ "$(head -n 1 $HOME/fivem/server/version_wanted.log)" != $VERSION_WANTED ]; then
    echo -e "\e[32mDownloading $VERSION_WANTED...\e[39m"
    wget -q --show-progress "https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/$VERSION_WANTED/fx.tar.xz" -P "$HOME/fivem/temp"
    echo Finished downloading FXServer
    echo Decompressing FXServer...
    echo -e "\e[93mIgnore warning/error below\e[39m"
    tar -xf "$HOME/fivem/temp/fx.tar.xz" -C "$HOME/fivem/server"
    echo Done decompressing FXServer
    echo $VERSION_WANTED > "$HOME/fivem/server/version_wanted.log"
    echo -e "\e[32mSuccessfully installed new FXServer build version $VERSION_WANTED\e[39m"
else
    echo Skipping FXServer, you already have the latest build
fi

if [ ! -d "$HOME/fivem/server-data/resources" ]; then
    echo -e "\e[32mCloning cfx-server-data to $HOME/fivem_test/server-data\e[39m"
    git clone https://github.com/citizenfx/cfx-server-data.git "$HOME/fivem/server-data"
    echo -e "\e[32mDone cloning cfx-server-data\e[39m"
else
    echo Found existing resources folder, skipping cloning cfx-server-data
fi

if [ ! -f "$HOME/fivem/server-data/server.cfg" ]; then
    echo -e "\e[32mCreating server.cfg...\e[39m"
    wget -q --show-progress "https://gist.githubusercontent.com/d0p3t/09d9ff1dc93d2534e7eb7c2712b163a9/raw/a382d32ad3e186bef85322eda52bd44bcb10e5e2/server.cfg" -P "$HOME/fivem/server-data"
    echo -e "\e[32mDone creating server.cfg in $HOME/fivem/server-data\e[39m"
    echo -e "Don't forget to add your license key to 'server.cfg'!"
else
    echo Found existing server.cfg, skipping creating server.cfg
fi


rm -rf "$HOME/fivem/temp"
echo -e "Deleted temp folder"

wget -O - https://raw.githubusercontent.com/XxTopKillerzZ/WebGere/master/install-scripts/mariadb/install.sh | bash

echo -e "\e[32mCompleted FXServer Setup!\e[39m"
echo
echo -e "Instructions to start server"
echo "1. 'cd $HOME/fivem/server-data'"
echo "2. 'Edit serve.cfg'"
echo "3. 'bash $HOME/fivem/server/run.sh +exec server.cfg'"
echo
echo "Enjoy!"
echo
