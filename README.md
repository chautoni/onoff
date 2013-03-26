# Server command
```
apt-get -y update
apt-get -y upgrade
apt-get -y install curl git-core python-software-properties software-properties-common

# nginx
add-apt-repository ppa:nginx/stable
apt-get -y update
apt-get -y install nginx
# check these two line in /etc/nginx/sites-available/default
# so that nginx won't bind to port 80 and [::]:80
# listen 80;
# listen [::]:80 default_server;
service nginx start

# SSL certificate for nginx

sudo mkdir /etc/nginx/ssl
cd /etc/nginx/ssl
sudo openssl genrsa -des3 -out server.key 1024
sudo openssl req -new -key server.key -out server.csr
# rememeber to put your domain or your vps ip in Common Name section
sudo cp server.key server.key.org
sudo openssl rsa -in server.key.org -out server.key
sudo openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt

# PostgreSQL
add-apt-repository ppa:pitti/postgresql
apt-get -y update
apt-get -y install postgresql-9.2 libpq-dev
sudo -u postgres psql
# \password
# create user blog with password 'secret';
# create database blog_production owner blog;
# \q

# Node.js
add-apt-repository ppa:chris-lea/node.js
apt-get -y update
apt-get -y install nodejs

# Add deployer user
groupadd admin
adduser kane --ingroup admin
su kane
mkdir .ssh
cat ~/.ssh/id_rsa.pub | ssh kane@198.211.127.54 'cat >> ~/.ssh/authorized_keys'

# rvm
# install under user kane
curl -L get.rvm.io | bash -s stable
echo 'source ~/.profile' > ~/.bash_login
rvm requirements
rvm install 1.9.3
rvm use 1.9.3 --default
gem update --sytem
gem install bundler

# After deploy:cold
sudo rm /etc/nginx/sites-enabled/default
sudo service nginx restart
sudo /usr/sbin/update-rc.d -f unicorn_onoff defaults
```
