#!/bin/bash

# Download MongoDB GPG key
curl -sSL https://www.mongodb.org/static/pgp/server-6.0.asc -o mongoserver.asc

# Import GPG key and export it to trusted keys
gpg --no-default-keyring --keyring ./mongo_key_temp.gpg --import ./mongoserver.asc
gpg --no-default-keyring --keyring ./mongo_key_temp.gpg --export > ./mongoserver_key.gpg
sudo mv mongoserver_key.gpg /etc/apt/trusted.gpg.d/

# Add Debian repository
echo "deb http://deb.debian.org/debian bullseye main" | sudo tee /etc/apt/sources.list.d/bullseye.list

# Update repositories
sudo apt update

# Install libssl1.1
sudo apt install libssl1.1

# Install MongoDB
sudo apt install mongodb-org

# Clean up temporary GPG keyring file
rm ./mongo_key_temp.gpg
