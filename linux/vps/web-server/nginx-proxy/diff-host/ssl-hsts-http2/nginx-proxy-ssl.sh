#!/bin/bash
https://raw.githubusercontent.com/thepwnexperts/advance-things/main/linux/vps/web-server/nginx-proxy/diff-host/ssl-hsts-http2/domain_and_ssl_op.sh
source domain_and_ssl_op.sh

# Initialize variables for HSTS, HTTP/2, domain, port, and proxy_host
enable_hsts=0
enable_http2=0
domain=""
port=""
proxy_host=""
add_domain=0
remove_domain=0
update_domain=0


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
        --add_domain)  # New flag for adding a domain
            add_domain=1
            shift
            ;;
        *)
            echo "Usage: $0 [--hsts] [--http2] [-d|--domain domain_name] [-p|--port port_number] [-ph|--proxy-host proxy_ip] [--add_domain]"
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


# Check if any of the domain-related flags are used
if [ "$add_domain" -eq 1 ] || [ "$remove_domain" -eq 1 ] || [ "$update_domain" -eq 1 ]; then
    # Do not ask for user input when one of the domain-related flags is used
    if [ "$add_domain" -eq 1 ]; then
        add_domain
    elif [ "$remove_domain" -eq 1 ]; then
        update_subdomain
    elif [ "$update_domain" -eq 1 ]; then
        remove_subdomain
    fi
else
    # Ask the user what they want to do if none of the domain-related flags are used
    echo "What do you want to do?"
    options=("Add domain" "Update subdomain" "Remove subdomain" "Quit")
    select opt in "${options[@]}"
    do
        case $opt in
            "Add subdomain")
                add_domain
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
fi
