#!/bin/bash

# Update and upgrade packages
echo "Updating and upgrading packages..."
sudo apt update && sudo apt upgrade -y

# Move otter.sh to /usr/local/bin and rename it to just "otter"
echo "Moving and renaming otter.sh to /usr/local/bin/..."
sudo mv otter.sh /usr/local/bin/
cd /usr/local/bin/
mv otter.sh otter

# Ensure it's executable
echo "Setting executable permissions..."
sudo chmod +x /usr/local/bin/otter

echo "Otter has been installed successfully! You can now type 'otter' in the terminal to run it."
