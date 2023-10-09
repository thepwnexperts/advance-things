#!/bin/bash

# Function to add a new subdomain
function add_subdomain() {
    echo "Adding a new subdomain..."

    # Ask for domain and application port number
    read -p "Enter domain name (e.g. example.com): " domain
    read -p "Enter application port number (e.g. 3000): " port

    # Create Nginx configuration file for subdomain
    config_file="/etc/nginx/sites-available/${domain}"
    cat > "${config_file}" << EOF
server {
    listen 80;
    listen [::]:80;

    server_name ${domain};

    location / {
        proxy_pass http://localhost:${port};
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

    # Create symbolic link to enable subdomain
    ln -s "${config_file}" "/etc/nginx/sites-enabled/${domain}"

    # Reload Nginx to apply changes
    systemctl reload nginx

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
            add_subdomain
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
