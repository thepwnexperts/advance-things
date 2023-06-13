#!/bin/bash

# Function to display script usage
usage() {
    echo "Usage: $0 [--device DEVICE] [--filesystem FILESYSTEM] [--mountpoint MOUNTPOINT] [--set-permissions] [--automount]"
    echo "Options:"
    echo "  --device DEVICE         Specify the device name (e.g., /dev/sdb)"
    echo "  --filesystem FILESYSTEM Specify the file system type (e.g., ext4)"
    echo "  --mountpoint MOUNTPOINT Specify the mount point directory (e.g., /storage)"
    echo "  --set-permissions      Set permissions for the mount point (optional)"
    echo "  --automount            Automatically mount the disk on boot (optional)"
    exit 1
}

# Function to prompt for yes/no confirmation
confirm() {
    read -p "$1 (y/n): " choice
    case "$choice" in
        y|Y|yes|YES) return 0 ;;
        *) return 1 ;;
    esac
}

# Process command-line parameters
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --device)
            device="$2"
            shift
            shift
            ;;
        --filesystem)
            filesystem="$2"
            shift
            shift
            ;;
        --mountpoint)
            mountpoint="$2"
            shift
            shift
            ;;
        --set-permissions)
            setpermissions="true"
            shift
            ;;
        --automount)
            automount="true"
            shift
            ;;
        *)
            # Unknown option
            usage
            ;;
    esac
done

# Check if required parameters are missing
if [[ -z $device || -z $filesystem || -z $mountpoint ]]; then
    echo "Missing required parameters!"
    usage
fi

# Check if the mount point directory already exists
if [[ -d $mountpoint ]]; then
    if ! confirm "The mount point directory $mountpoint already exists. Do you want to continue and force mount?"; then
        echo "Exiting..."
        exit 1
    fi
fi

# Prompt for formatting the disk
if confirm "Do you want to format the disk $device?"; then
    echo "Formatting the disk..."
    sudo mkfs.$filesystem $device
else
    echo "Skipping disk formatting..."
fi

# Creating the mount point
echo "Creating the mount point..."
sudo mkdir -p $mountpoint

# Mounting the disk
echo "Mounting the disk..."
sudo mount $device $mountpoint

# Setting permissions (if selected)
if [[ $setpermissions == "true" ]]; then
    echo "Setting permissions..."
    sudo chown -R $(whoami):$(whoami) $mountpoint
fi

# Automatically mount on boot (if selected)
if [[ $automount == "true" ]]; then
    echo "Configuring automatic mount on boot..."
    echo "$device   $mountpoint   $filesystem   defaults   0   2" | sudo tee -a /etc/fstab
fi

echo "Disk formatting and mounting complete!"
