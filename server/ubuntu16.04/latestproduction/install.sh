#!/bin/bash
#update repository list
apt update 
#Installation of dependencies
apt install -y apache2 mariadb-server libapache2-mod-php7.0 \
    php7.0-gd php7.0-json php7.0-mysql php7.0-curl \
    php7.0-intl php7.0-mcrypt php-imagick \
    php7.0-zip php7.0-xml php7.0-mbstring wget vim sudo lynx jq </dev/null
#Start Webserver
service apache2 start
#Add ownCloud repository and key
wget -nv https://download.owncloud.org/download/repositories/production/Ubuntu_16.04/Release.key -O Release.key
apt-key add - < Release.key
echo 'deb http://download.owncloud.org/download/repositories/production/Ubuntu_16.04/ /' > /etc/apt/sources.list.d/owncloud.list
#Update repository list
apt update 
#Install ownCloud 
apt install -y owncloud-files
#Script is written to be able to be ran after iterations. // Idempotenz  
cat <<EOT > /etc/apache2/sites-available/owncloud.conf
Alias /owncloud "/var/www/owncloud/"

<Directory /var/www/owncloud/>
  Options +FollowSymlinks
  AllowOverride All

 <IfModule mod_dav.c>
  Dav off
 </IfModule>

 SetEnv HOME /var/www/owncloud
 SetEnv HTTP_HOME /var/www/owncloud

</Directory>
EOT
ln -s /etc/apache2/sites-available/owncloud.conf /etc/apache2/sites-enabled/owncloud.conf
a2enmod rewrite
service apache2 restart
service mysql start
sleep 3

mysql -u root -e "create database owncloud"
mysql -u root -e "create user 'ownclouduser'@localhost identified by 'admin'"
mysql -u root -e "GRANT ALL PRIVILEGES ON owncloud. * TO 'ownclouduser'@'localhost'"

#./mysql.sh
#wait 


sudo -u www-data php /var/www/owncloud/occ maintenance:install --database "mysql" --database-name "owncloud" --database-user "ownclouduser" --database-pass "admin" --admin-user "admin" --admin-pass "admin"

. /etc/os-release

(echo "SUCCESS:$(lynx --dump localhost/owncloud/status.php| jq -r .versionstring ) installed! System $PRETTY_NAME" || echo "FAIL: Installation failed! System $PRETTY_NAME") >> /logs/server.install.log 2>&1 
