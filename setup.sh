sudo yum install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo setenforce 0
sed -i s\/^SELINUX=.*$\/SELINUX=disabled\/ \/etc\/selinux\/config
sudo yum install git -y
git clone https://github.com/atlasblue/webdev.git 
mv -f webdev/* /usr/share/nginx/html
ip = ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'
sed -i 's/x.x.x.x/$ip/g' /usr/share/nginx/html/index.html
