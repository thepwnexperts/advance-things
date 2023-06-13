#!/bin/bash

# Prompt for database name, username, and password
read -p "Enter database name: " DB_NAME
read -p "Enter database username: " DB_USER
read -sp "Enter database password: " DB_PASS

# Install MariaDB on supported distros
if [ -f /etc/os-release ]; then
  . /etc/os-release
  if [[ $ID == "ubuntu" || $ID == "debian" || $ID == "kali" ]]; then
    sudo apt update
    sudo apt install -y mariadb-server
  elif [[ $ID == "centos" || $ID == "rhel" || $ID == "fedora" ]]; then
    sudo yum update -y
    sudo yum install -y mariadb-server
  else
    echo "Unsupported distribution: $ID"
    exit 1
  fi
else
  echo "Unable to determine Linux distribution"
  exit 1
fi

# Start MariaDB service and enable it on boot
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Secure MariaDB installation
sudo mysql_secure_installation <<EOF
y
$DB_PASS
$DB_PASS
y
y
y
y
EOF

# Check if the user wants to change the root password
if [[ $DB_USER == "root" ]]; then
  # Change root password
  sudo mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_PASS';
FLUSH PRIVILEGES;
EOF

  # Check for errors
  if [ $? -ne 0 ]; then
    echo "Error changing root password"
    exit 1
  else
    echo "Root password changed successfully."
  fi
else
  # Create database and user
  sudo mysql -u root -p"$DB_PASS" <<EOF
CREATE DATABASE $DB_NAME;
CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EOF

  # Check for errors
  if [ $? -ne 0 ]; then
    echo "Error creating database and user"
    exit 1
  else
    echo "Database and user created successfully."
  fi
fi

# Restart MariaDB service
sudo systemctl restart mariadb
