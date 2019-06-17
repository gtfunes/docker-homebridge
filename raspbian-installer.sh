#!/bin/bash

#
# This script is meant for a quick and easy setup of oznu/homebridge on Raspbian
# It should be executed on a fresh install of Raspbian Stretch Lite only!
#

set -e

INSTALL_DIR=$HOME/homebridge
DOCKER_VERSION=18.06 # 18.09 has issues on raspberry pi zero

LP="[gtfunes/homebridge installer]"

# Step 0: Some basic configuration

echo "$LP Expanding filesystem..."

sudo raspi-config --expand-rootfs

echo "$LP Setting up locale..."

sudo sed -i "s/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" -i /etc/locale.gen
sudo locale-gen --purge en_US.UTF-8
sudo update-locale en_US.UTF-8

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Step 1: Install Docker

echo "$LP Installing Docker $DOCKER_VERSION..."

curl -fsSL https://get.docker.com -o get-docker.sh
chmod u+x get-docker.sh
sudo VERSION=$DOCKER_VERSION ./get-docker.sh
sudo usermod -aG docker $USER
rm -rf get-docker.sh

echo "$LP Docker Installed"

# Step 2: Install Docker Compose

echo "$LP Installing Docker Compose..."

sudo apt-get -y install python-setuptools
sudo easy_install pip
sudo pip install docker-compose~=1.23.0

# Step 3: Create Docker Compose Manifest

echo "$LP Docker Compose Installed"

mkdir -p $INSTALL_DIR
cd $INSTALL_DIR

echo "$LP Created $INSTALL_DIR"

PGID=$(id -g)
PUID=$(id -u)

cat >$INSTALL_DIR/docker-compose.yml <<EOL
version: '2'
services:
  homebridge:
    image: gtfunes/homebridge:raspberry-pi
    restart: always
    network_mode: host
    volumes:
      - ./config:/homebridge
    environment:
      - PGID=$PGID
      - PUID=$PUID
      - HOMEBRIDGE_CONFIG_UI=1
      - HOMEBRIDGE_CONFIG_UI_PORT=8080
EOL

echo "$LP Created $INSTALL_DIR/docker-compose.yml"

# Step 4: Pull Docker Image

echo "$LP Pulling Homebridge Docker image (this may take a few minutes)..."

sudo docker-compose pull

# Step 5: Start Container

echo "$LP Starting Homebridge Docker container..."

sudo docker-compose up -d

# Step 6: Wait for config ui to come up

echo "$LP Waiting for Homebridge to start..."

until $(curl --output /dev/null --silent --head --fail http://localhost:8080); do
  printf '.'
  sleep 5
done

echo

# Step 7: Success

IP=$(hostname -I)

echo "$LP"
echo "$LP Homebridge Installation Complete!"
echo "$LP You can access the Homebridge UI via:"
echo "$LP"

for ip in $IP; do
  if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "$LP http://$ip:8080"
  else
    echo "$LP http://[$ip]:8080"
  fi
done

echo "$LP"
echo "$LP Username: admin"
echo "$LP Password: admin"
echo "$LP"
echo "$LP Installed to: $INSTALL_DIR"
echo "$LP Thanks for installing gtfunes/homebridge!"

echo "$LP"
echo "$LP Rebooting Pi..."

sudo reboot
