# IP Address Management

IP Address Management (IPAM) adalah sistem yang digunakan untuk merencanakan, melacak, dan mengelola alamat IP dalam jaringan. Dengan semakin banyaknya perangkat dan layanan yang terhubung ke jaringan, manajemen IP yang efisien menjadi penting untuk menghindari konflik alamat, pemakaian IP yang berlebihan, atau kesalahan konfigurasi. IPAM membantu dalam mengotomatisasi proses distribusi, pengelolaan, dan pemantauan alamat IP, baik untuk jaringan IPv4 maupun IPv6. Dengan alat ini, administrator dapat menjaga ketersediaan, efisiensi, dan keamanan jaringan secara keseluruhan.

## Installation Guide
This is installation guide for installing PHPIPAM in Debian 11 (Bullseye) 

### Prerequisite
update repository dengan perintah berikut

```
apt update
```

install semua dependencies dan tools serta applikasi yang digunakan dalam kasus ini

```
apt install -y vim apache2 php-{mysql,curl,gd,intl,pear,imap,memcache,pspell,tidy,xmlrpc,mbstring,gmp,json,xml,fpm} libapache2-mod-php mariadb-client-core-10.6 mariadb-server-10.6
```

edit timezone pada file **php.ini** pada PHP-FPM
```
nano/vim /etc/php/*/fpm/php.ini
```
> ```
> [Date]
> date.timezone = Asia/Jakarta 
> ```

Restart service PHP-FPM untuk mendapatkan perubahannya
```
systemctl restart php*-fpm.service
```

### MariaDB SetUp
start dan enable MariaDB dengan melakukan perintah
```
systemctl enable --now mariadb
```

kemudian perkuat instans MariaDB dengan melakukan perintah
```
mysql_secure_installation
```

lakukan konfigurasi untuk membuat mariadb sekecil mungkin untuk memiliki celah keamanan

> ```
>Enter current password for root (enter for none):
> ...
>Switch to unix_socket authentication [Y/n] n
> ...
>Change the root password? [Y/n] n
> ...
>Remove anonymous users? [Y/n] y
> ...
>Disallow root login remotely? [Y/n] y
> ...
>Remove test database and access to it? [Y/n] y
> ...
>Reload privilege tables now? [Y/n] y
> ...
>Thanks for using MariaDB!
> ```

login ke MariaDB dengan melakukan perintah
```
mysql -u root
...
Enter password: password
```

konfigurasi database sebagai berikut
```
CREATE DATABASE phpipam;
GRANT ALL ON phpipam.* TO phpipam@localhost IDENTIFIED BY 'phpipam';
FLUSH PRIVILEGES;
QUIT;
```

### Install PHPIPAM on Debian 11
install git dan lakukkan clonning kepada repository phpipam ke directory ***/var/www/html/phpipam***
```
sudo apt install git
sudo git clone --recursive https://github.com/phpipam/phpipam.git /var/www/html/phpipam
```

pindah ke directory ***/var/www/html/phpipam***
```
cd /var/www/html/phpipam
```

copy **config.dist.php** to **config.php** dengan perintah berikut
```
cp config.dist.php config.php
```

edit database config pada file **config.php**
```
nano/vim config.php
```
>```
>$db['host'] = 'localhost';
>$db['user'] = 'phpipam';
>$db['pass'] = 'phpipam';
>$db['name'] = 'phpipam';
>$db['port'] = 3306;
>```

### Configure Apache2 
disable default apache configuration
```
cd /etc/apache2/sites-enabled/
mv 000-default.conf 000-default.conf.bak
```

edit file **phpipam.conf**
```
nano/vim /etc/apache2/sites-enabled/phpipam.conf
```

tambahkan file berikut [ini](config/phpipam-apache.conf)
>```
><VirtualHost *:80>
>    ServerAdmin webmaster@techviewleo.com
>    DocumentRoot "/var/www/html/phpipam"
>    ServerName ipam.techviewleo.com
>    ServerAlias www.ipam.techviewleo.com
>
>    <Directory "/var/www/html/phpipam">
>        Options Indexes FollowSymLinks
>        AllowOverride All
>        Require all granted
>    </Directory>
>    
>    ErrorLog "/var/log/apache2/phpipam-error_log"
>    CustomLog "/var/log/apache2/phpipam-access_log" combined
></VirtualHost>
>```

ubah ownership dari directory ***/var/www/html/***
```
chown -R www-data:www-data /var/www/html/
```

enable rewrite module untuk Apache
```
a2enmod rewrite
```

restart Apache untuk mengaktifkan perubahan
```
systemctl restart apache2
```

### Import Data to Database
jalankan perintah berikut ini untuk melakukan import data ke database
```
mysql -u root -p phpipam < /var/www/html/phpipam/db/SCHEMA.sql
...
Enter password: password
```

---
Open http://localhost for accessing the management console

### Tambahan
untuk automasi discovery bisa menggunakan cronjob, untuk melakukannya bisa menjalankan perintah berikut
```
sudo crontab -e
*/? * * * * /usr/bin/php /var/www/html/phpipam/functions/scripts/pingCheck.php
*/? * * * * /usr/bin/php /var/www/html/phpipam/functions/scripts/discoveryCheck.php

```
*ganti '?' sesuai dengan keinginan, value yang diizinkan adalah 1-59*

### Metode Lain
untuk mempermudah instalasi saya juga membuat beberapa cara untuk membuat phpipam dapat berjalan, antara lain adalah dengan menggunakan shell script dan juga menggunakan dockerfile yang bisa di unduh pada folder `method/` pada repository ini

---
untuk menggunakan metode shell script lakukan perintah berikut
```
chmod +x phpipam.sh
./phpipam.sh
```
dan untuk menggunakan metode docker lakukan perintah berikut
```
docker-compose up --build
```