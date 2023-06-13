# Swap File Creation Script

This is a bash script that creates a swap file on a VPS (Virtual Private Server) using command-line arguments. The script allows you to specify the size of the swap file, the file name, and whether to add the swap file to the `/etc/fstab` file for automatic activation on boot.

## Usage

To use this script, you can execute it with the following command:

```bash
bash swap.sh [-s <swap_size>] [-f <swap_file>] [-F <add_to_fstab>]
```

The script supports the following options:

- `-s <swap_size>`: Specifies the size of the swap file in megabytes (MB). If not provided, the default size is set to 4096 MB.
- `-f <swap_file>`: Specifies the path and name of the swap file to be created. If not provided, the default file name is set to `/swapfile`.
- `-F <add_to_fstab>`: Specifies whether to add the swap file to the `/etc/fstab` file for automatic activation on boot. Accepted values are `true` or `false`. If not provided, the default value is set to `true`.

## Example Usage

Create a swap file with a size of 2048 MB, named `/mnt/swapfile`, and add it to `/etc/fstab`:

```bash
bash swap.sh -s 2048 -f /mnt/swapfile -F true
```

## Prerequisites

- This script requires `sudo` privileges to run the necessary commands.
- The `fallocate`, `chmod`, `mkswap`, and `swapon` commands are used, so ensure that they are available on your system.

## Notes

- The script checks if a swap file with the specified name already exists. If it does, the script will exit without creating a new swap file.
- The swap file is created using `fallocate` command and set to the specified size. It is then given restrictive permissions using `chmod`, formatted as a swap area using `mkswap`, and finally activated using `swapon`.
- If the `-F` option is set to `true`, the script appends an entry to the `/etc/fstab` file to enable automatic activation of the swap file on system boot.

---

Feel free to modify and customize this script according to your needs.
