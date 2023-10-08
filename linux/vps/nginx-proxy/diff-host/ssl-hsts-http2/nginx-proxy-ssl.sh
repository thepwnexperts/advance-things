#!/bin/bash

# Initialize variables for HSTS, HTTP/2, domain, port, and proxy_host
enable_hsts=0
enable_http2=0
domain=""
port=""
proxy_host=""
add_domain=0  # Initialize the flag for adding a domain

# Parse command-line options
while [[ $# -gt 0 ]]; do
    case "$1" in
        --hsts)
            enable_hsts=1
            shift
            ;;
        --http2)
            enable_http2=1
            shift
            ;;
        -d|--domain)
            domain="$2"
            shift 2
            ;;
        -p|--port)
            port="$2"
            shift 2
            ;;
        -ph|--proxy-host)
            proxy_host="$2"
            shift 2
            ;;
        --add-d)  # New flag for adding a domain
            add_domain=1
            shift
            ;;
        *)
            echo "Usage: $0 [--hsts] [--http2] [-d|--domain domain_name] [-p|--port port_number] [-ph|--proxy-host proxy_ip] [--add-d]"
            exit 1
            ;;
    esac
done


# If domain is not provided via parameters, prompt the user
if [ -z "$domain" ]; then
  read -p "Enter domain name: " domain
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

# Function to add a new subdomain
function add_subdomain() {
    echo "Adding a new subdomain..."

# If proxy_host is not provided via parameters, prompt the user
if [ -z "$proxy_host" ]; then
  read -p "Enter proxy server host IP (e.g. 192.168.1.100): " proxy_host
fi

# If port is not provided via parameters, prompt the user
if [ -z "$port" ]; then
  read -p "Enter application port number (e.g. 3000): " port
fi

    # Create Nginx configuration file for subdomain
    config_file="/etc/nginx/sites-available/${domain}"
    cat > "${config_file}" << EOF
server {
    listen 80;
    listen [::]:80;
    server_name ${domain};

    location / {
        proxy_pass http://${proxy_host}:${port};
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
EOF

    # Add HSTS support if enabled
    if [ $enable_hsts -eq 1 ]; then
        cat >> "${config_file}" << EOF
    # Enable HSTS (HTTP Strict Transport Security)
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload";
EOF
    fi

    # Add HTTP/2 support if enabled
    if [ $enable_http2 -eq 1 ]; then
        cat >> "${config_file}" << EOF
    # Enable HTTP/2 support
    listen 443 ssl http2;
    ssl_certificate /etc/letsencrypt/live/${domain}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${domain}/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
EOF
    fi

    cat >> "${config_file}" << EOF
}
EOF

    # Create symbolic link to enable subdomain
    ln -s "${config_file}" "/etc/nginx/sites-enabled/${domain}"

    # Reload Nginx to apply changes
    systemctl reload nginx

    # Obtain SSL certificate using Certbot
    certbot --nginx -d ${domain}

    echo "Subdomain ${domain} added successfully!"
}




# Function to update an existing subdomain
function update_subdomain() {
    echo "Updating an existing subdomain..."

    # Ask for domain and application port number
    read -p "Enter domain name (e.g. example.com): " domain
    read -p "Enter application port number (e.g. 3000): " port

    # Check if subdomain configuration file exists
    config_file="/etc/nginx/sites-available/${domain}"
    if [[ ! -f "${config_file}" ]]; then
        echo "Subdomain ${domain} not found!"
        exit 1
    fi

    # Update Nginx configuration file for subdomain
    sed -i "s/proxy_pass http:\/\/localhost:[0-9]\+/proxy_pass http:\/\/localhost:${port}/" "${config_file}"

    # Reload Nginx to apply changes
    systemctl reload nginx

    echo "Subdomain ${domain} updated successfully!"
}

# Function to remove an existing subdomain
function remove_subdomain() {
    echo "Removing an existing subdomain..."

    # Ask for domain name
    read -p "Enter domain name (e.g. example.com): " domain

    # Check if subdomain configuration file exists
    config_file="/etc/nginx/sites-available/${domain}"
    if [[ ! -f "${config_file}" ]]; then
        echo "Subdomain ${domain} not found!"
        exit 1
    fi

    # Remove symbolic link to disable subdomain
    rm -f "/etc/nginx/sites-enabled/${domain}"

    # Remove configuration file for subdomain
    rm -f "${config_file}"

    # Reload Nginx to apply changes
    systemctl reload nginx

    echo "Subdomain ${domain} removed successfully!"
}



# Ask the user what they want to do
echo "What do you want to do?"
options=("Add subdomain" "Update subdomain" "Remove subdomain" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Add subdomain")
            if [ $add_domain -eq 1 ]; then
                add_subdomain
            else
                echo "Invalid option! To add a domain, use the --add-d flag."
            fi
            ;;
        "Update subdomain")
            update_subdomain
            ;;
        "Remove subdomain")
            remove_subdomain
            ;;
        "Quit")
            break
            ;;
        *)
            echo "Invalid option!"
            ;;
    esac
done
