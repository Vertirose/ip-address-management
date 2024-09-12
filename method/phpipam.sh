#!/bin/bash

# Warning
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo ""
echo "If there is a message to input the password, ensure to enter it as soon as possible!"
echo ""
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
sleep 10

# Installing Dependencies and Applications
echo "Updating repository..."
sleep 2
apt update -y
echo "Installing dependencies..."
sleep 2
apt install -y vim apache2 php-{mysql,curl,gd,intl,pear,imap,memcache,pspell,tidy,xmlrpc,mbstring,gmp,json,xml,fpm} libapache2-mod-php git
apt install -y mariadb-client-core-10.6 mariadb-server-10.6

# Setup TimeZone in PHP-FPM
echo "Setting timezone in PHP-FPM..."
sleep 2
sed -i 's#;date.timezone =#date.timezone = Asia/Jakarta#g' /etc/php/*/fpm/php.ini
echo "Restarting PHP-FPM service..."
sleep 2
systemctl restart php*-fpm.service

# Database Configurations
echo "Enabling and starting MariaDB..."
sleep 2
systemctl enable --now mariadb
echo "Securing MariaDB installation..."
sleep 2
mysql_secure_installation <<EOF

n
n
n
n
n
n
EOF

echo "Creating database for PHPIPAM..."
sleep 2
mysql -u root -p <<EOF
CREATE DATABASE phpipam;
GRANT ALL ON phpipam.* TO phpipam@localhost IDENTIFIED BY '1';
FLUSH PRIVILEGES;
EOF

# PHPIPAM Configurations
echo "Installing PHPIPAM..."
sleep 2
git clone --recursive https://github.com/phpipam/phpipam.git /var/www/html/phpipam
echo "Configuring PHPIPAM..."
sleep 2
cp /var/www/html/phpipam/config.dist.php /var/www/html/phpipam/config.php
sed -i "s/\$db\['host'\] =.*/\$db['host'] = 'localhost';/" /var/www/html/phpipam/config.php
sed -i "s/\$db\['user'\] =.*/\$db['user'] = 'phpipam';/" /var/www/html/phpipam/config.php
sed -i "s/\$db\['pass'\] =.*/\$db['pass'] = '1';/" /var/www/html/phpipam/config.php
sed -i "s/\$db\['name'\] =.*/\$db['name'] = 'phpipam';/" /var/www/html/phpipam/config.php
sed -i "s/\$db\['port'\] =.*/\$db['port'] = 3306;/" /var/www/html/phpipam/config.php

# Apache Configurations
echo "Configuring Apache..."
sleep 2
mv /etc/apache2/sites-enabled/000-default.conf /etc/apache2/sites-enabled/000-default.conf.bak
cat <<EOL > /etc/apache2/sites-enabled/phpipam.conf
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot "/var/www/html/phpipam"
    ServerName ipam.local
    ServerAlias www.ipam.local

    <Directory "/var/www/html/phpipam">
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog "/var/log/apache2/phpipam-error_log"
    CustomLog "/var/log/apache2/phpipam-access_log" combined
</VirtualHost>
EOL

echo "Setting correct ownership for /var/www/html..."
sleep 2
chown -R www-data:www-data /var/www/html/
echo "Enabling Apache rewrite module..."
sleep 2
a2enmod rewrite
echo "Restarting Apache..."
sleep 2
systemctl restart apache2

# Importing Data to Database
echo "Importing PHPIPAM database schema..."
sleep 2
mysql -u root -p phpipam < /var/www/html/phpipam/db/SCHEMA.sql

# Finish
echo "Installation completed! Access PHPIPAM via http://localhost"
sleep 2
sleep 2
echo "Use 'Admin' for user and 'ipamadmin' for password in default credentials"
sleep 2