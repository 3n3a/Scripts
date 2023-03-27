#!/bin/bash
#
#  INSTALL DOCKER on ROCKY LINUX
#
###############

echo "STARTING TO INSTALL DOCKER"
echo "========================="
echo ""

sudo yum install -y yum-utils
sudo yum-config-manager     --add-repo     https://download.docker.com/linux/centos/docker-ce.repo
sudo yum -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl start docker
