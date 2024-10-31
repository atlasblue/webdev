#!/bin/bash

#===================#
# For ROCKY Linux 9 #
#===================#

sudo dnf install nginx php php-fpm wget -y
sudo systemctl enable nginx
sudo systemctl start nginx
sudo systemctl enable php-fpm
sudo systemctl start php-fpm
user="nginx"
sed -i "s@user = apache@user = $user@g" /etc/php-fpm.d/www.conf
sed -i "s@group = apache@group = $user@g" /etc/php-fpm.d/www.conf
sudo systemctl restart php-fpm
serverRoot="/usr/share/nginx/html"
wget https://raw.githubusercontent.com/atlasblue/webdev/master/index.php -P $serverRoot
wget https://raw.githubusercontent.com/atlasblue/webdev/master/dev.png -P $serverRoot
rm -f /etc/nginx/conf.d/*
router="index.php"
domain="localhost"
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
