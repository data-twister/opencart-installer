#!/bin/bash
yum update -y
yum install -y httpd24 php56 mysql55-server php56-mysqlnd php56-mcrypt php56-gd git
PASSWORD= $(date | md5sum)
groupadd www
usermod -a -G www ec2-user apache 
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
mysql -uroot -e "CREATE database 'opencart'"
mysql -uroot -e "GRANT ALL PRIVILEGES ON `opencart`.* TO 'opencart-user'@'localhost'"
mysql -uroot -e "FLUSH PRIVILEGES"
mkdir Projects
cd Projects
git clone https://github.com/mithereal/opencart-installer.git
sudo opencart-installer/install
cd /var/www/http
HOSTNAME= $(curl http://169.254.169.254/latest/public-hostname)
opencart-install -n opencart -u opencart-user -d opencart -m $HOSTNAME -h $HOSTNAME  -v stable
