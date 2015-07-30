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
mysql -uroot -e "CREATE USER 'opencart-user' IDENTIFIED BY '$PASSWORD'"
mysql -uroot -e "CREATE DATABASE opencart"
mysql -uroot -e "GRANT ALL PRIVILEGES ON opencart.* TO 'opencart-user'"
mysql -uroot -e "FLUSH PRIVILEGES"
mkdir Projects
cd Projects
git clone https://github.com/mithereal/opencart-installer.git
chmod +x opencart-installer/install_aws
cd opencart-installer
./install_aws
cd /var/www/html
HOSTNAME=$(curl http://169.254.169.254/latest/meta-data/hostname)
install-opencart -n opencart -u ec2-user -d opencart -m $HOSTNAME -h $HOSTNAME  -v stable -N opencart-user -P $PASSWORD
