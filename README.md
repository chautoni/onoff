# Server command
```
apt-get -y update
apt-get -y upgrade
apt-get -y install curl git-core python-software-properties software-properties-common

# rvm
curl -L get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
rvm requirements
rvm install 1.9.3
rvm use 1.9.3 --default
gem update --sytem
gem install bundler
gem install passenger 
rvmsudo passenger-install-nginx-module


# nginx
add-apt-repository ppa:nginx/stable
apt-get -y update
apt-get -y install nginx
# check these two line in /etc/nginx/sites-available/default
# so that nginx won't bind to port 80 and [::]:80
# listen 80;
# listen [::]:80 default_server;
service nginx start

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
```
