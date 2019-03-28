#!/bin/bash
apt-get update
apt-get -y install apache2
apt-get -y install php libapache2-mod-php php-mysql
curl https://download.owncloud.org/download/repositories/10.0/Ubuntu_18.04/Release.key | apt-key add -
echo 'deb http://download.owncloud.org/download/repositories/10.0/Ubuntu_18.04/ /' | tee /etc/apt/sources.list.d/owncloud.list
apt-get update
apt-get -y install php-bz2 php-curl php-gd php-imagick php-intl php-mbstring php-xml php-zip owncloud-files
sed -i 's/\/var\/www\/html/\/var\/www\/owncloud/g' /etc/apache2/sites-enabled/000-default.conf
systemctl restart apache2