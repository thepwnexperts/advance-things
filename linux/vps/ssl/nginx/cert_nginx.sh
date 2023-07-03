#!/bin/bash

# Get domain name from command line argument or prompt
if [ -z "$1" ]
then
  read -p "Enter domain name: " domain
else
  domain=$1
fi

# Install Nginx and Certbot
if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y nginx certbot python3-certbot-nginx
elif command -v dnf >/dev/null 2>&1; then
  sudo dnf install -y nginx certbot python3-certbot-nginx
elif command -v yum >/dev/null 2>&1; then
  sudo yum install -y nginx certbot python3-certbot-nginx
else
  echo "Could not detect package manager. Please install Nginx and Certbot manually."
  exit 1
fi

# Create a default Nginx page
sudo tee /var/www/html/index.html >/dev/null <<EOF
<html>
<head>
  <title>Welcome to $domain!</title>
</head>
<body>
  <h1>Success! The $domain server block is working!</h1>
</body>
</html>
EOF

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
  <title>Welcome to $domain!</title>
</head>
<body>
  <h1>Success! The $DOMAIN server block is working!</h1>
  <h1>Success! The $domain server block is working!</h1>
</body>
</html>
EOF

# Enable the new server block configuration if not already enabled
if [ ! -f /etc/nginx/sites-enabled/$domain ]
then
  sudo ln -s /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/
fi

# Test the Nginx configuration
sudo nginx -t

# If the configuration test is successful, reload Nginx
if [ $? -eq 0 ]
then
  sudo systemctl reload nginx
fi

# Obtain SSL certificate from Let's Encrypt
if [ -z "$2" ]
then
  sudo certbot --nginx -d $domain
else
  sudo certbot --nginx -d $domain --register-unsafely-without-email
fi

# Add a cronjob to auto-renew the SSL certificate
(crontab -l 2>/dev/null | grep -v "certbot renew --nginx --quiet"; echo "0 0 * * 1 certbot renew --nginx --quiet") | crontab -
