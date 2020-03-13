#!/bin/bash
# Checkra1n Easy Installer
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

if [ "$EUID" -ne 0 ]
  then Print_Style "YOU AREN'T RUNNING AS ROOT! This script needs root, use sudo!" $RED
  exit
fi

if [ "$BASH_VERSION" = '' ]; then
    Print_Style "Warning: this script must be run in bash!" $RED
    exit
else
    Print_Style "Bash detected. Good." $GREEN
fi

# Downloads checkra1n
GetJB () {
  wget $DL_LINK
  chmod 755 checkra1n
}

# Check system architecture
CPUArch=$(uname -m)
Print_Style "System Architecture: $CPUArch" $YELLOW

# Get Linux distribution
# Stolen from Stack Overflow lol
if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS=Debian
    VER=$(cat /etc/debian_version)
elif [ -f /etc/SuSe-release ]; then
    # Older SuSE/etc.
    ...
elif [ -f /etc/redhat-release ]; then
    # Older Red Hat, CentOS, etc.
    ...
else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    VER=$(uname -r)
fi

# Determine Linux distro

if [[ "$OS" == *"Raspbian"* ]]; then
  DEPENDENCIES="usbmuxd libimobiledevice6"
  
else
  Print_Style "I don't know what dependencies you need for this distro. Using defaults for Raspbian..." $RED
  DEPENDENCIES="usbmuxd libimobiledevice6"
fi

# Choose correct download link
# TODO: dynamically fetch latest urls from checkra1n website
if [[ "$CPUArch" == *"aarch64"* || "$CPUArch" == *"arm64"* ]]; then
  Print_Style "ARM64 detected!" $YELLOW
  DL_LINK=https://assets.checkra.in/downloads/linux/cli/arm64/1985cee5704ed152d7a59efbcda5dab409824eeed5ebb23779965511b1733e28/checkra1n
  
elif [[ "$CPUArch" == *"armhf"* || "$CPUArch" == *"armv"* ]]; then
  Print_Style "ARM detected!" $YELLOW
  DL_LINK=https://assets.checkra.in/downloads/linux/cli/arm/c5cbb125c6948b39383702b62cec4f184263c8db50f49b9328013213126dae78/checkra1n
  
elif [[ "$CPUArch" == *"x86_64"* ]]; then
  Print_Style "x86_64 detected!" $YELLOW
  DL_LINK=https://assets.checkra.in/downloads/linux/cli/x86_64/9f215d8c5a1b6cea717c927b86840b9d1f713d42a24626be3a0408a4f6ba0f4d/checkra1n

elif [[ "$CPUArch" == *"x86"* ]]; then
  Print_Style "x86 detected!" $YELLOW
  DL_LINK=https://assets.checkra.in/downloads/linux/cli/i486/4785390cf41dfbf4478bce4b69a00ec00a82ebab0a1c8dc364a8fe1b6fc664c0/checkra1n

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
Print_Style "Attenpting to install dependencies." $BLUE
# TODO: detect if yum or others are needed
apt install -y $DEPENDENCIES
Print_Style "All done!" $BLUE
