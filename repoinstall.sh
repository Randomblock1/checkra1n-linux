#!/bin/bash
echo "Adding repo..."
echo "deb https://assets.checkra.in/debian /" | sudo tee -a /etc/apt/sources.list
sudo apt-key adv --fetch-keys https://assets.checkra.in/debian/archive.key
sudo apt update
echo "Installing..."
sudo apt install checkra1n
echo "Installing dependencies..."
sudo apt install usbmuxd
echo "All done!"
