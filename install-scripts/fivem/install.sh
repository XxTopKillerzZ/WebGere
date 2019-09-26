#!/bin/bash

function _printUsage()
{
    echo -n "$(basename $0) [OPTION]...
Fivem FxServer Installer.
Version $VERSION
    Options:
    	-v, --version       Fivem Version
        -h, --host       MySQL Host
        -rp, --rootpass   MySQL Root Password
        -d, --database    MySQL Database
        -u, --user        MySQL User
        -p, --pass        MySQL Password (If empty, auto-generated)
        -h, --help        Display this help and exit
    Examples:
        $(basename $0) --help
"
    exit 1
}

function processArgs()
{
    # Parse Arguments
    for arg in "$@"
    do
        case $arg in
	    -v=*|--version=*)
                VERSION_WANTED="${arg#*=}"
		#if ! [[ $VERSION_WANTED =~ ^[0-9]{4}-[a-zA-Z0-9]{40}$ ]] then
  		#	echo "Invalid Fivem Version"
		#	_printUsage
		#fi
		if ! { (curl -s "https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/" | grep "$VERSION_WANTED") && [[ $VERSION_WANTED =~ ^[0-9]{4}-[a-zA-Z0-9]{40}$ ]]; }; then
			echo "Invalid Fivem Version"
			_printUsage
		fi
            ;;
            -rp=*|--rootpass=*)
                rootPassword="${arg#*=}"
            ;;
            -d=*|--database=*)
                DB_NAME="${arg#*=}"
            ;;
            -u=*|--user=*)
                DB_USER="${arg#*=}"
            ;;
             -p=*|--pass=*)
                DB_PASS="${arg#*=}"
            ;;
            -h|--help)
                _printUsage
            ;;
            *)
                _printUsage
            ;;
        esac
    done
    if [[ -n $rootPassword ]] || [[ -n $DB_NAME ]] || [[ -n $DB_USER ]] || [[ -n $DB_PASS ]]; then
    	wantmysql=true
    elif [ -z $rootPassword ] && [ -z $DB_NAME ] && [ -z $DB_USER ] && [ -z $DB_PASS ]; then
    	wantmysql=false
    elif [[ -n $rootPassword ]] || [[ -n $DB_NAME ]] || [[ -n $DB_USER ]] || [[ -n $DB_PASS ]]; then
    	_printUsage
    fi
}

PrintFinalMessage() {
  if $wantmysql ; then
    ip="$(curl ifconfig.me)"
    
    echo "################################################################
    Installed Directory: $HOME/fivem
    Version Instaled: $VERSION_WANTED
    ################################################################
    Instructions to start server:
    
    cd $HOME/fivem/server-data
    Edit server.cfg
    bash $HOME/fivem/server/run.sh +exec server.cfg
    ################################################################
    Mysql host: $ip
    Mysql Root Password: 3306
    Mysql Port: $rootPassword
    Database Username: $DB_USER
    Database Password: $DB_PASS
    Database Name: $DB_NAME
    ################################################################" > $HOME/fivem/install_log.txt
    
    echo -e "\e[32mCompleted FXServer Setup!\e[39m"
    echo "################################################################"
    echo "Installed Directory: $HOME/fivem"
    echo "Version Instaled: $VERSION_WANTED"
    echo "################################################################"
    echo
    echo -e "Instructions to start server"
    echo "1. 'cd $HOME/fivem/server-data'"
    echo "2. 'Edit server.cfg'"
    echo "3. 'bash $HOME/fivem/server/run.sh +exec server.cfg'"
    echo
    echo "################################################################"
    echo
    echo -e "\e[32mThis info is also available at:$HOME/fivem/install_log.txt!\e[39m"
    echo
    echo "################################################################"
    echo
    echo "Mysql host: $ip"
    echo "Mysql Port: $rootPassword"
    echo "Mysql Root Password: 3306"
    echo "Database Username: $DB_USER"
    echo "Database Password: $DB_PASS"
    echo "Database Name: $DB_NAME"
    echo
    echo "################################################################"
    echo
    echo -e "\e[32mThis info is also available at:$HOME/fivem/install_log.txt!\e[39m"
    echo
    echo "################################################################"
    
  else
    echo "################################################################
    Installed Directory: $HOME/fivem
    Version Instaled: $VERSION_WANTED
    ################################################################
    Instructions to start server:
    
    cd $HOME/fivem/server-data
    Edit server.cfg
    bash $HOME/fivem/server/run.sh +exec server.cfg
    ################################################################" > $HOME/fivem/install_log.txt
  
  
    echo -e "\e[32mCompleted FXServer Setup!\e[39m"
    echo "################################################################"
    echo "Installed Directory: $HOME/fivem"
    echo "Version Instaled: $VERSION_WANTED"
    echo "################################################################"
    echo
    echo -e "Instructions to start server"
    echo "1. 'cd $HOME/fivem/server-data'"
    echo "2. 'Edit server.cfg'"
    echo "3. 'bash $HOME/fivem/server/run.sh +exec server.cfg'"
    echo
    echo "################################################################"
    echo
    echo -e "\e[32mThis info is also available at:$HOME/fivem/install_log.txt!\e[39m"
    echo
    echo "################################################################"
  fi
  exit 0
}

DatabaseInstall() {

	if command -v mysql >/dev/null 2>&1 ; then
   	 echo -e "\e[32mMysql is already Installed...\e[39m"
		echo -e "\e[32mVersion: $(mysql --version)\e[39m"
		DatabaseCreation
	else
    		echo -e "\e[32mInstalling Mysql...\e[39m"
	
		# default version
		MARIADB_VERSION='10.1'

		apt-get install -y software-properties-common

		# Import repo key
		sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db

		# Add repo for MariaDB
		sudo add-apt-repository "deb [arch=amd64,i386] http://mirrors.accretive-networks.net/mariadb/repo/$MARIADB_VERSION/ubuntu trusty main"

		# Update
		sudo apt-get update

		# Install MariaDB without password prompted
		sudo debconf-set-selections <<< "maria-db-$MARIADB_VERSION mysql-server/root_password password $ROOT_PASSWORD"
		sudo debconf-set-selections <<< "maria-db-$MARIADB_VERSION mysql-server/root_password_again password $ROOT_PASSWORD"

		# Install MariaDB
		# -qq implies -y --force-yes
		sudo apt-get install -qq mariadb-server

		# Make Maria connectable from outside world without SSH tunnel
		# enable remote access
		# setting the mysql bind-address to allow connections from everywhere
		sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
	
		DatabaseCreation
	fi


}

DatabaseCreation() {
	echo -e "\e[32mStarting databse creation...\e[39m"	
       	wget https://raw.githubusercontent.com/XxTopKillerzZ/WebGere/master/install-scripts/mariadb/create-database.sh -v -O create-database.sh && bash ./create-database.sh --host=localhost --database=$DATABASE_NAME --user=$DATABASE_USER --pass=$DATABASE_PASSWORD --rootpass=$ROOT_PASSWORD; rm -rf create-database.sh
	PrintFinalMessage
}

FivemInstalation() {

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
	if command -v git >/dev/null 2>&1 ; then
		echo -e "\e[32mTar Found...\e[39m"
	else
		echo -e "\e[32mInstalling Git...\e[39m"
		sudo apt-get install -y git
	fi
	if command -v curl >/dev/null 2>&1 ; then
		echo -e "\e[32mTar Found...\e[39m"
	else
		echo -e "\e[32mInstalling Curl...\e[39m"
		sudo apt-get install -y curl
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
	else
		echo Found existing server.cfg, skipping creating server.cfg
	fi


	rm -rf "$HOME/fivem/temp"
	echo -e "Deleted temp folder"
	
	if $wantmysql ; then
    	       DatabaseInstall
	else
		PrintFinalMessage
	fi
}

function generatePassword()
{
    echo "$(openssl rand -base64 12)"
}

function main()
{
    [[ $# -lt 1 ]] && _printUsage
    processArgs "$@"

    VERSION="v2.0"
    
    	echo -e "\e[32mAutomatic FXServer Setup Script for Ubuntu 18.04 LTS...\e[39m"
	echo
	echo -e "\e[32mAuthor: WebGere\e[39m"
	echo -e "\e[32mWebsite: https://webgere.pt\e[39m"
	echo
	echo -e "\e[32mCurrent Version: $VERSION\e[39m"
	echo
	echo
    
    FivemInstalation
    exit 0
}

export LC_CTYPE=C
export LANG=C

DB_USER=
DB_NAME=
DB_PASS=$(generatePassword)
rootPassword=$(generatePassword)
#DB_PASS=$(date +%s | sha256sum | base64 | head -c 14 ; echo)
#rootPassword=$(date +%s | sha256sum | base64 | head -c 14 ; echo)

main "$@"
