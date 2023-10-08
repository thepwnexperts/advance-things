```markdown
# Nginx Subdomain Management Script

This Bash script is designed to simplify the process of managing subdomains for Nginx web server configurations. It provides options to add, update, or remove subdomains, and automates the installation of Nginx and Certbot for SSL certificate management.

## Prerequisites

Before using this script, make sure you have the following prerequisites:

- A Linux-based system (tested with Ubuntu, Fedora, and CentOS)
- sudo privileges for executing certain commands
- A domain name that you want to configure subdomains for

## Usage

Follow these steps to use the script:

1. Clone the repository or download the script to your server:

   ```bash
   git clone https://github.com/your_username/nginx-subdomain-management.git
   cd nginx-subdomain-management
   ```

2. Make the script executable:

   ```bash
   chmod +x nginx-proxy-ssl.sh
   ```

3. Run the script:

   ```bash
   ./nginx-proxy-ssl.sh
   ```

4. You will be presented with a menu with the following options:

   - **Add subdomain**: Allows you to add a new subdomain to your Nginx configuration. You will be prompted to specify the proxy server host IP and application port number.

   - **Update subdomain**: Lets you update an existing subdomain by modifying the proxy_pass directive to point to a different port.

   - **Remove subdomain**: Allows you to remove an existing subdomain configuration.

   - **Quit**: Exits the script.


5. Follow the on-screen prompts to complete the desired action.

## Options
Suppose you want to add a new subdomain called `blog.example.com` that points to an application running on port `8080` on a proxy server with IP address `192.168.1.100`. You can use the script as follows:

```bash
./nginx-proxy-ssl.sh --hsts --http2 -d blog.example.com -p 8080 -ph 192.168.1.100
```

The script supports the following command-line options:

- `--hsts`: Enable HSTS (HTTP Strict Transport Security).
- `--http2`: Enable HTTP/2 support.
- `-d` or `--domain`: Specify the domain name.
- `-p` or `--port`: Specify the port number for the application.
- `-ph` or `--proxy-host`: Specify the proxy server host IP.

## Notes

- If you didn't provide the domain and other parameters via command-line options, you will be prompted to enter them during execution.

- The script will automatically install Nginx and Certbot if they are not already installed. If you prefer manual installation, follow the instructions provided in the script.

- The SSL certificate for the domain will be obtained using Certbot.

## License

This script is provided under the GNU General Public License, version 3.0 (GPL-3.0). You are free to use, modify, and distribute it under the terms of this license.

---


