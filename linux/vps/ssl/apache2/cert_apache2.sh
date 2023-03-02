#!/bin/bash

# Check if user is root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Detect distro and install certbot
if command -v apt-get >/dev/null 2>&1; then
  apt-get update
  apt-get install -y certbot python3-certbot-apache
elif command -v dnf >/dev/null 2>&1; then
  dnf install -y certbot python3-certbot-apache
elif command -v yum >/dev/null 2>&1; then
  yum install -y certbot python3-certbot-apache
else
  echo "Could not detect package manager. Please install certbot and python3-certbot-apache manually."
  exit 1
fi

# Prompt user for domain name and email address
read -p "Enter your domain name: " DOMAIN
read -p "Enter your email address: " EMAIL

# Check if Apache is installed
if ! command -v apache2 >/dev/null 2>&1; then
  echo "Apache2 is not installed. Please install Apache2 before running this script."
  exit 1
fi

# Create Apache virtual host file
cat > /etc/apache2/sites-available/$DOMAIN.conf << EOF
<VirtualHost *:80>
        ServerName $DOMAIN
        DocumentRoot /var/www/$DOMAIN
        <Directory /var/www/$DOMAIN>
                AllowOverride All
                Require all granted
        </Directory>
        ErrorLog ${APACHE_LOG_DIR}/$DOMAIN_error.log
        CustomLog ${APACHE_LOG_DIR}/$DOMAIN_access.log combined
</VirtualHost>
EOF

# Create default html file for virtual host
mkdir -p /var/www/$DOMAIN
cat > /var/www/$DOMAIN/index.html << EOF
<html>
<head>
  <title>Welcome to $DOMAIN!</title>
</head>
<body>
  <h1>Success! The $DOMAIN virtual host is working!</h1>
</body>
</html>
EOF

# Enable virtual host and reload Apache
a2ensite $DOMAIN.conf
systemctl reload apache2

# Allow HTTP and HTTPS traffic through firewall
if command -v ufw >/dev/null 2>&1; then
  ufw allow 'Apache Full'
elif command -v firewall-cmd >/dev/null 2>&1; then
  firewall-cmd --add-service=http --add-service=https --permanent
  firewall-cmd --reload
else
  echo "Could not detect firewall. Please allow HTTP and HTTPS traffic manually."
fi

# Run certbot to obtain SSL/TLS certificate
certbot --apache -d $DOMAIN -m $EMAIL --agree-tos --redirect --non-interactive

# Check if certificate installation was successful
if [ ! -f /etc/letsencrypt/live/$DOMAIN/fullchain.pem ]; then
  read -p "Certificate installation failed. Press any key to purge certbot and python3-certbot-apache and start from scratch."
  sudo apt purge certbot python3-certbot-apache
  exec bash $0
fi

# Add cronjob for automatic renewal of SSL/TLS certificate
(crontab -l ; echo "0 12 * * * /usr/bin/certbot renew --quiet") | crontab -
