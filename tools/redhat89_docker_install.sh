#!/bin/bash

echo "This script will try to install docker and docker compose for RedHat based linux distros (EL8 and EL9)."
echo "Press enter to continue."
read pressenter

sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io docker-compose-plugin
