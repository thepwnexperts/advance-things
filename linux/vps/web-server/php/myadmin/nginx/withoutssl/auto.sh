#!/bin/bash

# Check if running with root privileges
if [[ $EUID -ne 0 ]]; then
    echo "Please run the script with sudo or as root."
    exit 1
fi

# Prompt for domain/subdomain name
read -p "Enter the domain or subdomain name (e.g., phpmyadmin.example.com): " domain

# Install Nginx
sudo apt-get update
sudo apt-get install -y nginx

# Backup existing Nginx configuration for the domain
sudo cp "/etc/nginx/conf.d/${domain}.conf" "/etc/nginx/conf.d/${domain}.conf.bak"

# Install PHP and PHP-FPM
php_version=$(sudo apt-cache show php-fpm | grep Version | awk '{print $2}' | cut -d- -f1)
sudo apt-get install -y "php${php_version}-fpm" "php${php_version}-mysql"

# Download and extract phpMyAdmin
sudo mkdir /usr/share/phpmyadmin
sudo wget -qO- https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz | sudo tar xz --strip-components=1 -C /usr/share/phpmyadmin

# Create Nginx server block configuration for phpMyAdmin
sudo tee "/etc/nginx/conf.d/${domain}.conf" > /dev/null <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name ${domain};

    root /usr/share/phpmyadmin;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php${php_version}-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

# Restart Nginx
sudo systemctl restart nginx

echo "phpMyAdmin installation and configuration completed."
echo "You can access phpMyAdmin at http://${domain}"
