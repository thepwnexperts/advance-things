#!/bin/bash

# Add Kali Linux repository
echo "deb http://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware" | sudo tee /etc/apt/sources.list
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ED444FF07D8D0BF6

# Update repositories
apt-get update
apt dist-upgrade -y

# Install packages
apt-get install -y htop bpytop neofetch

# Install additional packages
apt-get install -y npm nodejs
npm install -g pm2 uuid

# Download and run swap script
wget https://raw.githubusercontent.com/thepwnexperts/advance-things/main/linux/vps/swap/swap.sh
chmod +x swap.sh
./swap.sh

# Download and run update script
wget https://raw.githubusercontent.com/thepwnexperts/advance-things/main/linux/vps/debian/auto/update_cron/update.sh
chmod +x update.sh
./update.sh

# Clean up downloaded scripts
rm swap.sh update.sh
