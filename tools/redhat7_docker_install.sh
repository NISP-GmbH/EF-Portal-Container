#!/bin/bash

echo "This script will try to install docker and docker compose for RedHat based linux distros (EL7)."
echo "You need to have epel-release available."
echo "Press enter to continue."
read pressenter

sudo yum -y install epel-release
sudo yum -y install yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
