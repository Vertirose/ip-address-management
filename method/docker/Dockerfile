FROM debian:bullseye

# Install dependencies
RUN DEBIAN_FRONTEND=noninteractive \
    && apt-get update -qq \
    && apt-get install -y \
        apache2 \
        libapache2-mod-php \
        php-mysql \
        php-gmp \
        php-gd \
        php-ldap \
        php-pear \
        php-snmp \
        php-mbstring \
        php-curl \
        unzip \
        vim \
        curl \
        iputils-ping \
        fping \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download and install PHPIPAM
ADD https://github.com/phpipam/phpipam/archive/master.zip /tmp/
RUN unzip /tmp/master.zip -d /tmp/ \
    && mkdir /var/www/html/phpipam/ \
    && cp -R /tmp/phpipam-master/* /var/www/html/phpipam/ \
    && rm /tmp/master.zip

# Copy configuration files
COPY config/apache.conf /etc/apache2/sites-available/000-default.conf
COPY config/config.php /var/www/html/phpipam/config.php

# Set Apache environment variables
ENV APACHE_LOCK_DIR /var/lock
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2/
ENV APACHE_PID_FILE /var/apache.pid

# Enable Apache mod_rewrite
RUN a2enmod rewrite \
    && chown -R www-data:www-data /var/www/html

# Expose ports
EXPOSE 80

# Start Apache
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
