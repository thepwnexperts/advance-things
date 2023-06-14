#!/bin/bash

# Function to prompt user for missing required argument
prompt_argument() {
  read -p "Enter $1: " value
  echo "$value"
}


# Function to check for duplicate entry in crontab
check_duplicate_entry() {
  local cron_entry="$1"
  crontab -l | grep -q -F "$cron_entry"
}

# Check if user is root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
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

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    -v|--php-version)
      PHP_VERSION="$2"
      shift
      shift
      ;;
    -d|--domain)
      DOMAIN="$2"
      shift
      shift
      ;;
    -e|--email)
      EMAIL="$2"
      shift
      shift
      ;;
    *)
      echo "Invalid argument: $1"
      exit 1
      ;;
  esac
done

# Prompt user for missing required arguments
if [ -z "$PHP_VERSION" ]; then
  PHP_VERSION=$(prompt_argument "the PHP version (e.g., 8.0, 7.4)")
fi

if [ -z "$DOMAIN" ]; then
  DOMAIN=$(prompt_argument "your domain name")
fi

if [ -z "$EMAIL" ]; then
  EMAIL=$(prompt_argument "your email address")
fi

# Install PHP and PHP-FPM
sudo apt-get install -y "php${PHP_VERSION}-fpm" "php${PHP_VERSION}-mysql"

# Enable and start php-fpm service
systemctl enable --now php${PHP_VERSION}-fpm

# Check if nginx is installed and install if necessary
if ! command -v nginx >/dev/null 2>&1; then
  echo "nginx is not installed. Installing nginx..."
  if command -v apt-get >/dev/null 2>&1; then
    apt-get install -y nginx
  elif command -v dnf >/dev/null 2>&1; then
    dnf install -y nginx
  elif command -v yum >/dev/null 2>&1; then
    yum install -y nginx
  else
    echo "Could not install nginx. Please install nginx manually."
    exit 1
  fi
fi

# Create nginx server block file
cat > /etc/nginx/sites-available/$DOMAIN << EOF
server {
    listen 80 ;
    listen [::]:80 ;
    server_name $DOMAIN ;
    root /var/www/$DOMAIN/public ;
    index index.php index.html index.htm ;
    location / {
        try_files \$uri \$uri/ /index.php\$is_args\$args ;
    }
    location ~ \.php$ {
        include snippets/fastcgi-php.conf ;
        fastcgi_pass unix:/var/run/php/php${PHP_VERSION}-fpm.sock ;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name ;
        include fastcgi_params ;
    }
}
EOF

# Update php-fpm configuration
php_fpm_conf="/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"
if [ -f "$php_fpm_conf" ]; then
  sed -i "s/^listen =.*/listen = \/var\/run\/php\/php${PHP_VERSION}-fpm.sock/" "$php_fpm_conf"
fi

# Create default index.php file for server block
mkdir -p /var/www/$DOMAIN/public
cat > /var/www/$DOMAIN/public/index.php << EOF
<?php
phpinfo();
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
cron_entry="0 12 * * * /usr/bin/certbot renew --quiet"
if ! check_duplicate_entry "$cron_entry"; then
  (crontab -l ; echo "$cron_entry") | crontab -
  echo "Cronjob added for automatic certificate renewal."
else
  echo "Cronjob for automatic certificate renewal already exists."
fi
