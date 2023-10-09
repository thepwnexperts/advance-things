#!/bin/bash

# Define the script file name and location
SCRIPT_FILE="/usr/local/bin/update"

# Generate the script content
cat << EOF > $SCRIPT_FILE
#!/bin/bash

# Set the DEBIAN_FRONTEND variable to noninteractive
export DEBIAN_FRONTEND=noninteractive

# Update the package lists
apt-get update

# Upgrade any available packages
apt-get dist-upgrade -y
EOF

# Make the script executable
chmod +x $SCRIPT_FILE

# Define the cron job schedule (every Sunday at 00:00 UTC+5:30)
CRON_SCHEDULE="0 0 * * 0"

# Add the cron job to the current user's crontab
(crontab -l 2>/dev/null; echo "$CRON_SCHEDULE $SCRIPT_FILE") | crontab -

echo "Cron job added to run $SCRIPT_FILE every Sunday at 00:00 UTC+5:30."

#Cleaning unwanted Packages

sudo apt clean
echo "Cleaning Packages!!" 
