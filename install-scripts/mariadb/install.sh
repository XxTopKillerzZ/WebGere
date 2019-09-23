#!/bin/bash

echo -e "\e[32mAutomatic MariaDB Setup Script for Ubuntu 18.04 LTS...\e[39m"
echo
echo -e "\e[32mAuthor: WebGere\e[39m"
echo -e "\e[32mWebsite: https://webgere.pt\e[39m"
echo
echo -e "\e[32mCurrent Version: v0.1\e[39m"
echo


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
else
     
fi

# Install MariaDB without password prompt
# Set username to 'root' and password to 'mariadb_root_password' (see Vagrantfile)
sudo debconf-set-selections <<< "maria-db-$MARIADB_VERSION mysql-server/root_password password $ROOT_PASSWORD"
sudo debconf-set-selections <<< "maria-db-$MARIADB_VERSION mysql-server/root_password_again password $ROOT_PASSWORD"

# Install MariaDB
# -qq implies -y --force-yes
sudo apt-get install -qq mariadb-server

# Make Maria connectable from outside world without SSH tunnel
# enable remote access
# setting the mysql bind-address to allow connections from everywhere
sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

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
    else
      
    fi
    
    
    
    
    
    
    #Credentials
    echo -e "\e[32mDatabase User: $DATABASE_USER...\e[39m"
    echo -e "\e[32mDatabase Password: $DATABASE_PASSWORD...\e[39m"
    echo -e "\e[32mDatabase Name: $DATABASE_NAME...\e[39m"
    
else
    echo -e "\e[32mSkiping Database creation\e[39m"
fi

echo -e "\e[32mMysql Password: $ROOT_PASSWORD...\e[39m"

fi
