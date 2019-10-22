#!/bin/bash
apt-get update
apt-get -y install apache2
apt-get -y install php 
apt-get -y install libapache2-mod-php 
apt-get -y install php-mysql
curl https://download.owncloud.org/download/repositories/production/Ubuntu_18.04/Release.key | apt-key add -
echo 'deb http://download.owncloud.org/download/repositories/production/Ubuntu_18.04/ /' > /etc/apt/sources.list.d/owncloud.list
apt-get update
apt-get -y install php-bz2
apt-get -y install php-curl 
apt-get -y install php-gd 
apt-get -y install php-imagick 
apt-get -y install php-intl 
apt-get -y install php-mbstring 
apt-get -y install php-xml 
apt-get -y install php-zip 
apt-get -y install owncloud-files
sed -i 's/\/var\/www\/html/\/var\/www\/owncloud/g' /etc/apache2/sites-enabled/000-default.conf
systemctl restart apache2