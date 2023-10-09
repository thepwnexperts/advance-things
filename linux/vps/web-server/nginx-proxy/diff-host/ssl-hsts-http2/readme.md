# Nginx Proxy with SSL Management Script

## Overview
This Bash script simplifies the setup and management of Nginx with SSL (via Certbot) for web domains. It provides options for enabling HSTS, HTTP/2, specifying the domain, port, and proxy host, and managing subdomains. Whether you want to add, update, or remove a subdomain, this script automates the process.

## Features
- Easy setup and configuration of Nginx with SSL.
- Enable or disable HSTS and HTTP/2.
- Manage subdomains with ease.
- Support for multiple package managers (apt-get, dnf, yum).

## Usage

### Running the Script

1. Clone this repository to your local machine.
   ```bash
   wget https://raw.githubusercontent.com/thepwnexperts/advance-things/main/linux/vps/web-server/nginx-proxy/diff-host/ssl-hsts-http2/nginx-proxy-ssl.sh
   ```

2. Make the script executable.
   ```bash
   chmod +x nginx-proxy-ssl.sh
   ```

3. Run the script with appropriate options. Here is an example:

   - **Add a Subdomain for `example.com` with proxy host `localhost` on port `6001`:**
     ```bash
     ./nginx-proxy-ssl.sh --add_domain -d example.com -ph localhost -p 6001
     ```

5. Follow the on-screen prompts and instructions to complete the configuration.

## Example

Let's say you want to add a subdomain for `example.com` with a proxy host set to `localhost` on port `6001`. You can use the following command:

```bash
./nginx-proxy-ssl.sh --add_domain -d example.com -ph localhost -p 6001
```

This command will run the script, configuring Nginx with SSL and a proxy for the specified subdomain and settings.

## License
This project is licensed under the GNU General Public License v3.0. See the [LICENSE](LICENSE) file for details.

## Acknowledgments
Special thanks to the open-source community for their contributions and support.

Feel free to contribute, report issues, or provide feedback!

```
