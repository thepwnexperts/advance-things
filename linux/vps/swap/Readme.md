

# Swap File Creation Script

This bash script simplifies the creation of a swap file on a VPS (Virtual Private Server) using command-line arguments. The script enables specifying the size of the swap file, the file name, and whether to add the swap file to the `/etc/fstab` file for automatic activation on boot.

## Usage

To use this script, execute it using the following command:

```bash
wget -O swap.sh https://raw.githubusercontent.com/thepwnexperts/advance-things/main/linux/vps/swap/swap.sh
chmod +x swap.sh
./swap.sh [-s <swap_size>] [-f <swap_file>] [-F <add_to_fstab>]
```

The script supports the following options:

- `-s <swap_size>`: Specifies the size of the swap file in megabytes (MB). If not provided, the default size is set to 2048 MB (2 GB).
- `-f <swap_file>`: Specifies the path and name of the swap file to be created. If not provided, the default file name is set to `/swapfile`.
- `-F <add_to_fstab>`: Specifies whether to add the swap file to the `/etc/fstab` file for automatic activation on boot. Accepted values are `true` or `false`. If not provided, the default value is set to `true`.

## Example Usage

Create a swap file with a size of 4096 MB (4 GB), named `/swapfile`, and add it to `/etc/fstab`:

```bash
./swap.sh -s 4096 -f /swapfile -F true
```

```
wget -O swap.sh https://raw.githubusercontent.com/thepwnexperts/advance-things/main/linux/vps/swap/swap.sh
chmod +x swap.sh
./swap.sh -s 4096 -f /swapfile -F true
```

## Prerequisites

- This script requires `sudo` privileges to execute the necessary commands.
- Ensure that the `fallocate`, `chmod`, `mkswap`, and `swapon` commands are available on your system.

## Notes

- The script verifies if a swap file with the specified name already exists. If it does, the script will exit without creating a new swap file.
- It creates the swap file using the `fallocate` command and sets it to the specified size. Subsequently, it applies restrictive permissions using `chmod`, formats it as a swap area using `mkswap`, and finally activates it using `swapon`.
- If the `-F` option is set to `true`, the script appends an entry to the `/etc/fstab` file to enable automatic activation of the swap file on system boot.

Feel free to adapt and customize this script based on your requirements.

