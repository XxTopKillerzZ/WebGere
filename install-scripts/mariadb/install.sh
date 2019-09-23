#!/bin/bash

echo -e "\e[32mAutomatic MariaDB Setup Script for Ubuntu 18.04 LTS...\e[39m"
echo
echo -e "\e[32mAuthor: WebGere\e[39m"
echo -e "\e[32mWebsite: https://webgere.pt\e[39m"
echo
echo -e "\e[32mCurrent Version: v0.1\e[39m"
echo

DatabaseCreation() {
    	read -p "Do you want to create a database? " -n 1 -r
	echo    # (optional) move to a new line
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		echo -e "\e[32mDatabase User Name:\e[39m"
		while [[ $DATABASE_USER = "" ]]; do
			read DATABASE_USER
		done
		
		echo -e "\e[32mDatabase Name:\e[39m"
		while [[ $DATABASE_NAME = "" ]]; do
			read DATABASE_NAME
		done
    
		echo -e "\e[32mDatabase Password: (Leave Blank for Random)\e[39m"
		read DATABASE_PASSWORD
		if [ -z "$DATABASE_PASSWORD" ]
		then
			echo -e "\e[32mGenerating Password\e[39m"
			DATABASE_PASSWORD=$(date +%s | sha256sum | base64 | head -c 15 ; echo)
			echo -e "\e[32msuccessfully Generated password...\e[39m"
		fi
    		create_file="/tmp/create-database.sh"
		if [ -f "$create_file" ]
		then
			rm -r ./tmp/create-database.sh
		fi
		wget -P /tmp https://raw.githubusercontent.com/XxTopKillerzZ/WebGere/master/install-scripts/mariadb/create-database.sh
		chmod a+x ./tmp/create-database.sh
		./tmp/create-database.sh --host=localhost --database=$DATABASE_NAME --user=$DATABASE_USER --pass=$DATABASE_PASSWORD --rootpass=$ROOT_PASSWORD
		rm -r ./tmp/create-database.sh
  
    
	else
		echo -e "\e[32mSkiping Database creation\e[39m"
		echo -e "\e[32mMysql Root Password: $ROOT_PASSWORD\e[39m"
	fi
}


if command -v mysql >/dev/null 2>&1 ; then
    echo -e "\e[32mMysql is already Installed...\e[39m"
	echo -e "\e[32mBersion: $(mysql --version)\e[39m"
	DatabaseCreation
else
    	echo -e "\e[32mInstalling Mysql...\e[39m"
	
	# default version
	MARIADB_VERSION='10.1'

	apt-get update

	apt-get install -y software-properties-common

	# Import repo key
	sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db

	# Add repo for MariaDB
	sudo add-apt-repository "deb [arch=amd64,i386] http://mirrors.accretive-networks.net/mariadb/repo/$MARIADB_VERSION/ubuntu trusty main"

	# Update
	sudo apt-get update

	echo -e "\e[32mPlease write a root password for mysql. Leave blank for random\e[39m"
	read ROOT_PASSWORD
	if [ -z "$ROOT_PASSWORD" ]
	then
		echo -e "\e[32mGenerating Password\e[39m"
		ROOT_PASSWORD=$(date +%s | sha256sum | base64 | head -c 15 ; echo)
		echo -e "\e[32msuccessfully Generated password...\e[39m" 
	fi

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
