#!/bin/bash
mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh
yum install -y docker
mkdir mynginx
cd /vagrant/ && cp Dockerfile test.conf index.html /home/vagrant/mynginx/
systemctl enable docker
systemctl start docker