#!/bin/bash
mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
mkdir mynginx
cp /vagrant/Dockerfile /vagrant/test.conf /vagrant/index.html /home/vagrant/mynginx/
systemctl enable containerd.service
systemctl enable docker.service
systemctl start containerd.service
systemctl start docker.service
cd /home/vagrant/mynginx/
docker build -t docker-nginx:v1 .
docker run -d -p 80:8080 docker-nginx:v1
curl -L "https://github.com/docker/compose/releases/download/v2.6.1/docker-compose-linux-x86_64" -o /usr/local/sbin/docker-compose
cp -R /vagrant/compose /home/vagrant/
cd /home/vagrant/compose/
docker-compose up -d