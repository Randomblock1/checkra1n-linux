#!/bin/bash
# Checkra1n Easy Install
# GitHub Repository: https://github.com/Randomblock1/Checkra1n-Linux

# Terminal colors
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
LIME_YELLOW=$(tput setaf 190)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BRIGHT=$(tput bold)
NORMAL=$(tput sgr0)
BLINK=$(tput blink)
REVERSE=$(tput smso)
UNDERLINE=$(tput smul)

# Prints a line with color using terminal codes
Print_Style () {
  printf "%s\n" "${2}$1${NORMAL}"
}

# Downloads checkra1n
GetJB () {
  wget $DL_LINK
  chmod 755 checkra1n
}

# Check system architecture
CPUArch=$(uname -m)
Print_Style "System Architecture: $CPUArch" $YELLOW

# Choose correct download link
# TODO: dynamically fetch latest urls from checkra1n website
if [[ "$CPUArch" == *"aarch64"* || "$CPUArch" == *"arm64"* ]]; then
  Print_Style "ARM64 detected!" $YELLOW
  DL_LINK=https://assets.checkra.in/downloads/linux/cli/arm64/0a640fd52276d5640bbf31c54921d1d266dc2303c1ed26a583a58f66a056bfea/checkra1n
  
elif [[ "$CPUArch" == *"armhf"* || "$CPUArch" == *"armv"* ]]; then
  Print_Style "ARM detected!" $YELLOW
  DL_LINK=https://assets.checkra.in/downloads/linux/cli/arm/5f7d4358971eb2823413801babbac0158524da80c103746e163605d602ff07bf/checkra1n
  
elif [[ "$CPUArch" == *"x86_64"* ]]; then
  Print_Style "x86_64 detected!" $YELLOW
  DL_LINK=https://assets.checkra.in/downloads/linux/cli/x86_64/eda98d55f500a9de75aee4e7179231ed828ac2f5c7f99c87442936d5af4514a4/checkra1n

elif [[ "$CPUArch" == *"x86"* ]]; then
  Print_Style "x86 detected!" $YELLOW
  DL_LINK=https://assets.checkra.in/downloads/linux/cli/i486/26952e013ece4d0e869fc9179bfd2b1f6c319cdc707fadf44fdb56fa9e62f454/checkra1n

else
  Print_Style "ERROR: Unknown/Unsuported architecture! Please try again, make sure your architecture is supported by checkra1n and that you're using sh instead of bash." $RED
  DL_LINK=UNKNOWN
  exit
fi

Print_Style "Getting checkra1n..." $GREEN
GetJB
Print_Style "Done! Marked as executable!" $GREEN

echo -n "Install to /usr/bin (y/n)?"
  read answer
  if [ "$answer" != "${answer#[Yy]}" ]; then
    sudo cp checkra1n /usr/bin
    Print_Style "Copied executable to /usr/bin" $GREEN
  echo -n "Delete downloaded file (no longer needed)? (y/n)"
    read answer
    if [ "$answer" != "${answer#[Yy]}" ]; then
    rm checkra1n
    fi
  fi
if [ -f "/etc/debian_version" ];
    Print_Style "Debian detected! Getting dependencies!" $BLUE
    ## I think these are the only dependencies needed, but I'm not entirely sure
    apt install -y usbmuxd libimobiledevice6
fi
Print_Style "All done!" $BLUE