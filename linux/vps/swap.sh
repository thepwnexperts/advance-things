#!/bin/bash
#Create swap on VPS using bash script via arguments
#Parse command-line arguments

while getopts ":s:f:" opt; do
case $opt in
s)
SWAP_SIZE=$OPTARG
;;
f)
SWAP_FILE=$OPTARG
;;
?)
echo "Invalid option: -$OPTARG" >&2
exit 1
;;
:)
echo "Option -$OPTARG requires an argument." >&2
exit 1
;;
esac
done
#Check if swap size and file were provided

if [ -z "$SWAP_SIZE" ] || [ -z "$SWAP_FILE" ]; then
echo "Swap size or file name not provided. Exiting."
exit 1
fi
#Check if swap already exists

if swapon -s | grep -q "$SWAP_FILE"; then
echo "Swap file $SWAP_FILE already exists. Exiting."
exit
fi
#Create the swap file

sudo fallocate -l ${SWAP_SIZE}M "$SWAP_FILE"
sudo chmod 600 "$SWAP_FILE"
sudo mkswap "$SWAP_FILE"
sudo swapon "$SWAP_FILE"
#Ask user if they want to add swap file to /etc/fstab

read -p "Do you want to add the swap file to /etc/fstab? (y/n) " ANSWER
if [[ "$ANSWER" =~ ^[Yy]$ ]]; then
echo "$SWAP_FILE none swap sw 0 0" | sudo tee -a /etc/fstab
echo "Swap file added to /etc/fstab."
else
echo "Swap file not added to /etc/fstab."
fi

echo "Swap file $SWAP_FILE created successfully."
