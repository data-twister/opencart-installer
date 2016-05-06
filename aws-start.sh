#!/bin/bash
yum update -y
yum install -y httpd24 php56 mysql55-server php56-mysqlnd php56-mcrypt php56-gd git
PASSWORD= $(date | md5sum)
groupadd www
usermod -a -G www ec2-user 
usermod -a -G www  apache 
chown -R apache:www /var/www
chgrp -R www /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} +
find /var/www -type f -exec chmod 0664 {} +
service httpd start
service mysqld start
chkconfig httpd on
chkconfig mysqld on
mysql -uroot -e "CREATE USER 'opencart-user'@'localhost' IDENTIFIED BY '$PASSWORD'"
mysql -uroot -e "CREATE database opencart"
mysql -uroot -e "GRANT ALL PRIVILEGES ON opencart.* TO 'opencart-user'@'localhost'"
mysql -uroot -e "FLUSH PRIVILEGES"
mkdir Projects
cd Projects
git clone https://github.com/mithereal/opencart-installer.git
cd opencart-installer
./install
cd /var/www/html
HOSTNAME= $(curl http://169.254.169.254/latest/meta-data/hostname)
install-opencart -n opencart -u ec2-user -d opencart -m $HOSTNAME -h $HOSTNAME  -v stable -w opencart-user -r $PASSWORD -g mysqli

cd ~
curl -sS https://getcomposer.org/installer | sudo php
mv composer.phar /usr/local/bin/composer
ln -s /usr/local/bin/composer /usr/bin/composer

cd /var/www/html

composer install
