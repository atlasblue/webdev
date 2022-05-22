sudo yum update -y
sudo yum install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
systemctl stop firewalld
systemctl disable firewalld
sudo yum install git -y
sudo git clone https://github.com/atlasblue/webdev.git 
sudo mv -f webdev/* /usr/share/nginx/html
