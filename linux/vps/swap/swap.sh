#!/bin/bash
#Create swap on VPS using bash script via arguments
#Parse command-line arguments

while getopts ":s:f:F:" opt; do
case $opt in
s)
SWAP_SIZE=$OPTARG
;;
f)
SWAP_FILE=$OPTARG
;;
F)
ADD_TO_FSTAB=$OPTARG
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

#Use default values if swap size or file name not provided
SWAP_SIZE=${SWAP_SIZE:-4096}
SWAP_FILE=${SWAP_FILE:-/swapfile}
ADD_TO_FSTAB=${ADD_TO_FSTAB:-true}

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

#Add swap file to /etc/fstab if specified
if [[ $ADD_TO_FSTAB == true ]]; then
echo "$SWAP_FILE none swap sw 0 0" | sudo tee -a /etc/fstab
echo "Swap file added to /etc/fstab."
else
echo "Swap file not added to /etc/fstab."
fi

echo "Swap file $SWAP_FILE created successfully."

