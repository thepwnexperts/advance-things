#!/bin/bash

# Check if user is root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Detect distro and install certbot
if command -v apt-get >/dev/null 2>&1; then
  apt-get update
  apt-get install -y certbot python3-certbot-nginx
elif command -v dnf >/dev/null 2>&1; then
  dnf install -y certbot python3-certbot-nginx
elif command -v yum >/dev/null 2>&1; then
  yum install -y certbot python3-certbot-nginx
else
  echo "Could not detect package manager. Please install certbot and python3-certbot-nginx manually."
  exit 1
fi

# Prompt user for domain name and email address
read -p "Enter your domain name: " DOMAIN
read -p "Enter your email address: " EMAIL

# Check if nginx is installed
if ! command -v nginx >/dev/null 2>&1; then
  echo "nginx is not installed. Please install nginx before running this script."
  exit 1
fi

# Create nginx server block file
cat > /etc/nginx/sites-available/$DOMAIN << EOF
server {
        listen 80 ;
        listen [::]:80 ;
        server_name $DOMAIN ;
        root /var/www/$DOMAIN ;
        index index.html index.htm index.nginx-debian.html ;
        location / {
                try_files \$uri \$uri/ =404 ;
        }
}
EOF

# Create default html file for server block
mkdir -p /var/www/$DOMAIN
cat > /var/www/$DOMAIN/index.html << EOF
<html>
<head>
  <title>Welcome to $DOMAIN!</title>
</head>
<body>
  <h1>Success! The $DOMAIN server block is working!</h1>
</body>
</html>
EOF

# Create symbolic link to enable server block
ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/$DOMAIN

# Test nginx configuration and reload if successful
nginx -t && systemctl reload nginx

# Allow HTTP and HTTPS traffic through firewall
if command -v ufw >/dev/null 2>&1; then
  ufw allow 'Nginx Full'
elif command -v firewall-cmd >/dev/null 2>&1; then
  firewall-cmd --add-service=http --add-service=https --permanent
  firewall-cmd --reload
else
  echo "Could not detect firewall. Please allow HTTP and HTTPS traffic manually."
fi

# Run certbot to obtain SSL/TLS certificate
certbot --nginx -d $DOMAIN -m $EMAIL --agree-tos --redirect --non-interactive

# Add cronjob for automatic renewal of SSL/TLS certificate
(crontab -l ; echo "0 12 * * * /usr/bin/certbot renew --quiet") | crontab -

