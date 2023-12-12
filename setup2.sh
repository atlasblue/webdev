#!/bin/bash

#================#
# For CentOS 7.0 #
#================#


######## CONFIG ##########

user="user"
router="index.php"
serverRoot="/usr/share/nginx/html"
domain="localhost"
timezone="America/Phoenix"

##########################

useradd $user

# Repos
rpm -Uvh https://mirror.webtatic.com/yum/el7/epel-release.rpm
rpm -Uvh http://yum.postgresql.org/9.3/redhat/rhel-7-x86_64/pgdg-centos93-9.3-1.noarch.rpm
rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

# Installation
yum install rsync nginx php56w-fpm php56w-gd php56w-mbstring php56w-pecl-xdebug php56w-pgsql php56w-bcmath php56w-opcache php56w-mcrypt php56w wget -y

#Configuration
su - postgres -c /usr/pgsql-9.3/bin/initdb

#php-fpm configuration
sed -i "s@;date.timezone =@date.timezone = $timezone@g" /etc/php.ini
sed -i "s@display_errors = Off@display_errors = On@g" /etc/php.ini
sed -i "s@html_errors = On@html_errors = Off@g" /etc/php.ini
sed -i "s@;catch_workers_output =@catch_workers_output =@g" /etc/php-fpm.d/www.conf
sed -i "s@;php_flag\[display_errors\] = off@php_flag\[display_errors\] = on@" /etc/php-fpm.d/www.conf

# permissions
sed -i "s@user  nginx@user  $user@g" /etc/nginx/nginx.conf
sed -i "s@user = apache@user = $user@g" /etc/php-fpm.d/www.conf
sed -i "s@group = apache@group = $user@g" /etc/php-fpm.d/www.conf
sed -i "s@group = apache@group = $user@g" /etc/php-fpm.d/www.conf
sed -i "s@SELINUX=enforcing@SELINUX=disabled@g" /etc/sysconfig/selinux
systemctl stop firewalld
systemctl disable firewalld
setenforce 0

echo "
<?php
echo '<h1>Server configured successfully!</h1>';
" > $serverRoot/$router
curl -OL https://github.com/atlasblue/webdev/blob/e8ff82fa35f6989d1ff1aef31e8503595c11171b/dev.png
chown $user /home/$user -R
chgrp $user /home/$user -R

rm -f /etc/nginx/conf.d/*
echo "
server {
    listen       80;
    server_name  l localhost $domain www.$domain;
    root $serverRoot;
    index $router;
    location / {
        try_files \$uri \$uri/ /$router;
    }
    location ~ \.php$ {
        fastcgi_index   $router;
        fastcgi_pass    127.0.0.1:9000;
        include         fastcgi_params;
        fastcgi_param   SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
}
" > /etc/nginx/conf.d/server.conf


# start at boot
systemctl enable php-fpm
systemctl enable nginx

# run them
systemctl start php-fpm
systemctl start nginx
