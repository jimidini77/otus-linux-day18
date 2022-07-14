#!/bin/bash
mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh
yum install -y docker
mkdir mynginx
cp /vagrant/Dockerfile /vagrant/test.conf /vagrant/index.html /home/vagrant/mynginx/
systemctl enable docker
systemctl start docker
cd /home/vagrant/mynginx/
docker build -t docker-nginx:v1 .
docker run -d -p 80:8080 docker-nginx:v1