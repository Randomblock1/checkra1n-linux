#!/bin/bash
# Checkra1n Installer for All Architectures
# GitHub Repository: https://github.com/Randomblock1/checkra1n-linux
# shellcheck disable=SC2034,SC1091
SCRIPT_VERSION=2.3
# Set terminal colors
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

# Set whiptail dialog size
LINES=$(tput lines)
COLUMNS=$(tput cols)
LISTHEIGHT=5

# Prints a line with color using terminal codes
Print_Style () {
  printf "%s\n" "${2}$1${NORMAL}"
}

# This is a bash script. Can also run in zsh.
if [[ "$BASH_VERSION" == '' && "$ZSH_VERSION" == '' ]]; then
  whiptail --msgbox "ERROR: this script must be run in bash/zsh!" 20 30 --ok-button "Exit"
  echo "ERROR: this script must be run in bash/zsh!"
  exit
fi

# We need root.
if [ "$EUID" -ne 0 ]; then
  whiptail --msgbox "YOU AREN'T RUNNING AS ROOT! This script needs root, use sudo!" $((LINES*3/4)) $((COLUMNS*7/10)) --ok-button "Exit"
  Print_Style "ERROR: You need to run this as root, use sudo!" "$RED"
  exit
fi


# Check system architecture
CPUArch=$(uname -m)
Print_Style "System Architecture: $CPUArch" "$YELLOW"

# Get Linux distribution
# https://unix.stackexchange.com/a/6348
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


# Checkra1n requires some libraries to work properly.
if ! command -v curl &> /dev/null; then
  Print_Style "cURL could not be found, attempting to install" "$RED"
  apt install -y curl
fi

if ! command -v grep &> /dev/null; then
  Print_Style "grep could not be found, attempting to install" "$RED"
  apt install -y grep
fi

if ! command -v whiptail &> /dev/null; then
  Print_Style "whiptail could not be found, attempting to install" "$RED"
  apt install -y whiptail
fi

if ! test -f "/usr/share/doc/libimobiledevice6/copyright"; then
  Print_Style "libimobiledevice6 could not be found, attempting to install" "$RED"
  apt install -y libimobiledevice6
fi

if ! test -f "/usr/sbin/usbmuxd"; then
  Print_Style "usbmuxd could not be found, attempting to install" "$RED"
  apt install -y usbmuxd
fi

# Find latest checkra1n version (for autoupdate).
CHECKRA1NVERSION=$(curl https://checkra.in/ -s | grep "checkra1n .\..*\.." -oE | grep ".\..*\.." -oE)

# Automatically find latest checkra1n for correct architecture.
GetDL () {
  FindDL() {
    DL_LINK=$(curl -s https://checkra.in/releases/ | grep "https:\/\/assets.checkra.in\/downloads\/linux\/cli\/$1\/.*\/checkra1n" -o)
  }
Print_Style "Getting latest download..." "$YELLOW"
    if [[ "$CPUArch" == *"aarch64"* || "$CPUArch" == *"arm64"* ]]; then
      Print_Style "ARM64 detected!" "$YELLOW"
      FindDL arm64

    elif [[ "$CPUArch" == *"armhf"* || "$CPUArch" == *"armv"* ]]; then
      Print_Style "ARM detected!" "$YELLOW"
      FindDL arm

    elif [[ "$CPUArch" == *"x86_64"* ]]; then
      Print_Style "x86_64 detected!" "$YELLOW"
      FindDL x86_64

    elif [[ "$CPUArch" == *"x86"* || "$CPUArch" == *"i686"* ]]; then
      Print_Style "x86 detected!" "$YELLOW"
      FindDL i486

    else
      Print_Style "ERROR: Unknown/Unsupported architecture! Make sure your architecture is supported by checkra1n." "$RED"
      Print_Style "Manually select architecture. Options are arm64, armv7, x86_64 and x86." "$RED"
      read -rp "Architecture: "
      CPUArch="$REPLY"
      GetDL
    fi
}

# Automatic script self-update logic
ScriptUpdate () {
ONLINE_VERSION="$(curl -s https://raw.githubusercontent.com/Randomblock1/checkra1n-linux/master/installer.sh | head -n 5 | tail -c 4)"
if (( $(echo "$ONLINE_VERSION > $SCRIPT_VERSION" | bc -l) )); then
  Print_Style "Script needs to be updated! Updating..." "$GREEN"
    wget -q https://raw.githubusercontent.com/Randomblock1/checkra1n-linux/master/installer.sh -O installer.sh
    chmod 755 installer.sh
    Print_Style "Completed!" "$GREEN"
    whiptail --title "Script Updated" --msgbox "This script has been automatically updated to version $ONLINE_VERSION!" $((LINES*3/4)) $((COLUMNS*7/10))
    ./installer.sh
    exit
else
  Print_Style "Script is already up to date!" "$GREEN"
fi
}

# Is our checkra1n up to date?
Checkra1nChecker () {
if ! test "$HOME/.cache"; then
  mkdir ~/.cache
fi
if test -f ~/.cache/checkra1n-version; then
  INSTALLEDVERSION=$(cat ~/.cache/checkra1n-version)
  if [ "$CHECKRA1NVERSION" != "$INSTALLEDVERSION" ]; then
    if (whiptail --title "Checkra1n Update" --yesno "An update for checkra1n is available ($(cat ~/.cache/checkra1n-version) to $CHECKRA1NVERSION). Update?" $((LINES*3/4)) $((COLUMNS*7/10))); then
      DirectDL
    fi
  else
    Print_Style "Checkra1n is up to date!" "$GREEN"
  fi
  else
  # If checkra1n exists, assume we are up-to-date. Otherwise, let it autoupdate.
  if test -f /usr/bin/checkra1n; then
    echo "$CHECKRA1NVERSION" > ~/.cache/checkra1n-version
  else
    echo 0.00.0 > ~/.cache/checkra1n-version
  fi
fi
}

# Installs Procursus bootstrap interactively.
Procursify () {
if (whiptail --title "Procursify" --yesno "Would you like to install the Procursus/odysseyra1n bootstrap?\n\
This will allow you to use libhooker, a replacement for Substrate, and the Procursus repo tools.\n\
Procursus tools are more up-to-date than other repos.\n\
Libhooker has been reported to be slightly more stable and efficient than Substrate, but no real testing has been done." $((LINES*3/4)) $((COLUMNS*7/10))); then
  if (whiptail --title "Procursify" --yes-button "Continue" --no-button "Cancel" --yesno "It's time to prepare your device.\n\
  Please do all of the following to continue.\n\
  1. Backup your tweaks with applist, batchomatic, or backupaz3.\n\
  2. Restore RootFS\n\
  3. Jailbreak but DO NOT OPEN THE CHECKRA1N LOADER ON YOUR device\n\
  4. Continue here" "$LINES" "$COLUMNS"); then
    if ! command -v iproxy &> /dev/null; then
      Print_Style "iproxy could not be found, attempting to install" "$RED"
      apt install -y libusbmuxd-tools
    fi
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/coolstar/Odyssey-bootstrap/master/procursus-deploy-linux-macos.sh)"
    iproxy 4444 44 >> /dev/null 2>/dev/null &
    echo "Default password is: alpine"
    ssh -p4444 -o "StrictHostKeyChecking no" -o "UserKnownHostsFile=/dev/null" root@127.0.0.1 "apt update && apt install org.coolstar.libhooker -y && /etc/rc.d/libhooker && sbreload"
    whiptail --title "Procursify" --msgbox "Success! Enjoy your libhooker." $((LINES*3/4)) $((COLUMNS*7/10))
  fi
fi
}

# Called when we want to directly download checkra1n.
DirectDL () {
  GetOS
  GetDL
  Print_Style "Getting checkra1n..." "$GREEN"
  curl "$DL_LINK" -o /usr/bin/checkra1n
  chmod 755 /usr/bin/checkra1n
  Print_Style "Done! Marked as executable!" "$GREEN"
  echo "$CHECKRA1NVERSION" > ~/.cache/checkra1n-version
  Print_Style "All done!" "$BLINK"
}

# Check if we can use the repo; otherwise, exit.
InstallRepo () {
if [[ "$CPUArch" == *"x86_64"* ]]; then
  Print_Style "x86_64 detected!" "$GREEN"
else
  Print_Style "ERROR:You aren't on x86_64! You can't use this! Exiting..." "$RED"
  exit
fi
echo "Adding repo..."
echo "deb https://assets.checkra.in/debian /" | sudo tee -a /etc/apt/sources.list
sudo apt-key adv --fetch-keys https://assets.checkra.in/debian/archive.key
sudo apt update
echo "Installing..."
sudo apt install checkra1n
echo "All done!"
}

# Print credits.
GetCredits () {
  NET_IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -1)
  whiptail --title "Checkra1n GUI Installer" --msgbox "Checkra1n GUI Installer made by Randomblock1.\n\
  This project is open source! Check out https://github.com/Randomblock1/Checkra1n-Linux! \n\
  Follow me on Twitter @randomblock1_! \n\
  Please report all bugs in the GitHub issue tracker and feel free to make pull requests! \n\
  INFO: $OS $(uname -mo) \n\
  VERSION: $SCRIPT_VERSION \n\
  Local IP: $NET_IP" $((LINES*3/4)) $((COLUMNS*7/10)) $((LISTHEIGHT))
  MainMenu
}

# Main menu. Uses whiptail.
function MainMenu() {
  CHOICE=$(whiptail \
  --title "Checkra1n GUI Installer on $(uname -m)" \
  --menu "Choose an option" $((LINES*3/4)) $((COLUMNS*7/10)) $((LISTHEIGHT)) \
    "Install Repo" "Install the repo. x86_64 ONLY!" \
    "Direct Download" "Use on any architecture." \
    "Procursify" "Install Procursus bootstrap." \
    "Credits" "This tool is open-source!" \
    "Update/Reinstall" "Update this tool." 3>&1 1>&2 2>&3)
  case $CHOICE in
    "Install Repo")
    InstallRepo
    ;;
    "Direct Download")
    DirectDL
    ;;
    "Procursify")
    Procursify
    ;;
    "Credits")
    GetCredits
    ;;
    "Update/Reinstall")
    whiptail --title "Checkra1n GUI Installer" --yesno "Force update to latest version?" $((LINES*3/4)) $((COLUMNS*7/10))
    case $? in
      1)
      MainMenu
      ;;
      0)
      SCRIPT_VERSION=0.0
      ScriptUpdate
    esac
  esac
}

# Main function. Check script, then checkra1n, then enter the main menu.
ScriptUpdate
Checkra1nChecker
MainMenu
