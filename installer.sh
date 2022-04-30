#!/bin/bash
# Checkra1n Installer for All Architectures
# GitHub Repository: https://github.com/Randomblock1/checkra1n-linux
# shellcheck disable=SC2034,SC1091,SC2089
SCRIPT_VERSION=3.1
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
LISTHEIGHT=6

# Prints a line with color using terminal codes
Print_Style() {
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
  whiptail --msgbox "YOU AREN'T RUNNING AS ROOT! This script needs root, use sudo!" $((LINES * 3 / 4)) $((COLUMNS * 7 / 10)) --ok-button "Exit"
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
else
  # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
  OS=$(uname -s)
  VER=$(uname -r)
fi

# This script and Checkra1n requires some things to work properly.
CheckDep() {
  if dpkg -s "$1" &>/dev/null || which "$1" || sudo -u "$SUDO_USER" brew list "$1"; then
    Print_Style "Dependency check: $1 installed." "$GREEN"
  else
    Print_Style "Dependency check: $1 NOT installed. Installing..." "$RED"
    if [ "$OS" != "Darwin" ]; then
      apt install -y "$1" -qq >/dev/null 2>/dev/null || (
        Print_Style "WARNING: $1 failed to install." "$RED"
        exit
      )
    else
      sudo -u "$SUDO_USER" brew install "$1" -q >/dev/null 2>/dev/null || (
        Print_Style "WARNING: $1 failed to install." "$RED"
        exit
      )
    fi
    Print_Style "$1 installed." "$GREEN"
  fi
}

CheckDep curl
CheckDep grep
CheckDep usbmuxd
if [ "$OS" = "Darwin" ]; then
  CheckDep newt
  CheckDep libimobiledevice
else
  CheckDep whiptail
  CheckDep libimobiledevice6
  CheckDep libimobiledevice-utils
fi

# We need Internet
if ! curl -sI http://google.com >/dev/null; then
  Print_Style "No internet connection!" "$RED"
  exit
fi

# Find latest checkra1n version (for autoupdate).
CHECKRA1NVERSION=$(curl https://checkra.in/ -s | grep "checkra1n .\..*\.." -oE | grep ".\..*\.." -oE)

# Automatically find latest checkra1n for correct architecture.
GetDL() {
  FindDL() {
    DL_LINK=$(curl -s https://checkra.in/releases/ | grep "https:\/\/assets.checkra.in\/downloads\/linux\/cli\/$1\/.*\/checkra1n" -o)
  }
  Print_Style "Getting latest download..." "$YELLOW"
  if [[ "$CPUArch" == "aarch64*" || "$CPUArch" == "arm64" ]]; then
    Print_Style "ARM64 detected!" "$YELLOW"
    FindDL arm64

  elif [[ "$CPUArch" == "armhf" || "$CPUArch" == "armv*" ]]; then
    Print_Style "ARM detected!" "$YELLOW"
    FindDL arm

  elif [[ "$CPUArch" == "x86_64" ]]; then
    Print_Style "x86_64 detected!" "$YELLOW"
    FindDL x86_64

  elif [[ "$CPUArch" == "x86" || "$CPUArch" == "i*86" ]]; then
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
ScriptUpdate() {
  ONLINE_VERSION="$(curl -s https://raw.githubusercontent.com/Randomblock1/checkra1n-linux/master/installer.sh | head -n 5 | tail -c 4)"
  if (($(echo "$ONLINE_VERSION > $SCRIPT_VERSION" | bc -l))); then
    Print_Style "Script needs to be updated! Updating..." "$GREEN"
    sudo -u "$SUDO_USER" wget -q https://raw.githubusercontent.com/Randomblock1/checkra1n-linux/master/installer.sh -O installer.sh
    chmod 755 installer.sh
    Print_Style "Completed!" "$GREEN"
    whiptail --title "Script Updated" --msgbox "This script has been automatically updated to version $ONLINE_VERSION!" $((LINES * 3 / 4)) $((COLUMNS * 7 / 10))
    ./installer.sh
    exit
  else
    Print_Style "Script is already up to date!" "$GREEN"
  fi
}

# Is our checkra1n up to date?
Checkra1nChecker() {
  if ! test "$HOME/.cache"; then
    mkdir ~/.cache
  fi
  if test -f ~/.cache/checkra1n-version; then
    INSTALLEDVERSION=$(cat ~/.cache/checkra1n-version)
    if [ "$CHECKRA1NVERSION" != "$INSTALLEDVERSION" ]; then
      if (whiptail --title "Checkra1n Update" --yesno "An update for checkra1n is available ($(cat ~/.cache/checkra1n-version) to $CHECKRA1NVERSION). Update?" $((LINES * 3 / 4)) $((COLUMNS * 7 / 10))); then
        DirectDL
      fi
    else
      Print_Style "Checkra1n is up to date!" "$GREEN"
    fi
  else
    # If checkra1n exists, assume we are up-to-date. Otherwise, let it autoupdate.
    if test -f /usr/bin/checkra1n; then
      echo "$CHECKRA1NVERSION" >~/.cache/checkra1n-version
    else
      echo 0.00.0 >~/.cache/checkra1n-version
    fi
  fi
}

# Installs Procursus bootstrap interactively.
Procursify() {
  if (whiptail --title "Procursify" --yesno "Would you like to install the Procursus/odysseyra1n bootstrap?\n\
This will allow you to use libhooker, a replacement for Substrate, and the Procursus repo tools.\n\
Procursus tools are more up-to-date than other repos.\n\
Libhooker is slightly more stable and efficient than Substrate and Substitute." $((LINES * 3 / 4)) $((COLUMNS * 7 / 10))); then
    if ! command -v iproxy &>/dev/null; then
      Print_Style "iproxy could not be found, attempting to install" "$RED"
      apt install -y libusbmuxd-tools
    fi
    sudo -u "$SUDO_USER" /bin/bash -c "./procursify.sh"
    whiptail --title "Procursify" --msgbox "Success! Enjoy your libhooker." $((LINES * 3 / 4)) $((COLUMNS * 7 / 10))
  fi
}

# Called when we want to directly download checkra1n.
DirectDL() {
  GetOS
  GetDL
  Print_Style "Getting checkra1n..." "$GREEN"
  curl "$DL_LINK" -o /usr/bin/checkra1n
  chmod 755 /usr/bin/checkra1n
  Print_Style "Done! Marked as executable!" "$GREEN"
  echo "$CHECKRA1NVERSION" >~/.cache/checkra1n-version
  Print_Style "All done!" "$BLINK"
}

# Check if we can use the repo; otherwise, exit.
InstallRepo() {
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

# Save blobs using 1Conan TSSSaver API
TssSaver() {
  Print_Style "TSS Saver Activated!" "$PURPLE"
  Print_Style "Getting info about your device..." "$PURPLE"
  if ! ideviceinfo -s -k ProductVersion; then
    Print_Style "No device detected!" "$RED"
    Print_Style "Check that your device is plugged in!" "$RED"
    exit
  fi
  device="$(ideviceinfo -s -k ProductType)"
  board="$(ideviceinfo -s -k HardwareModel)"
  ecid="$(ideviceinfo -s -k UniqueChipID)"
  Print_Style "Device: $device" "$PURPLE"
  Print_Style "Board: $board" "$PURPLE"
  Print_Style "ECID (decimal): $ecid" "$PURPLE"
  Print_Style "Requesting https://tsssaver.1conan.com to save our blobs..." "$WHITE"
  request="{\"boardConfig\":\"$board\",\"ecid\":\"$ecid\",\"deviceIdentifier\":\"$device\"}"
  sleep 1
  curl -X POST -d "$request" https://tsssaver.1conan.com/v2/api/save.php || exit
  Print_Style "Success! View your saved blobs at https://tsssaver.1conan.com/shsh/$ecid" "$GREEN"
  Print_Style "If you want to save blobs for your device without this tool, just run this command:" "$GREEN"
  Print_Style "curl -X POST -d $request https://tsssaver.1conan.com/v2/api/save.php" "$WHITE"
}

# Print credits.
GetCredits() {
  if dpkg -s "net-tools" &>/dev/null; then
    NET_IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -1)
  else
    NET_IP=N/A
  fi
  whiptail --title "Checkra1n GUI Installer" --msgbox "Checkra1n GUI Installer made by Randomblock1.\n\
  This project is open source! Check out https://github.com/Randomblock1/Checkra1n-Linux! \n\
  Follow me on Twitter @randomblock1_! \n\
  Please report all bugs in the GitHub issue tracker and feel free to make pull requests! \n\
  INFO: $OS $(uname -mo) \n\
  VERSION: $SCRIPT_VERSION \n\
  Local IP: $NET_IP" $((LINES * 3 / 4)) $((COLUMNS * 7 / 10)) $((LISTHEIGHT))
  MainMenu
}

# Main menu. Uses whiptail.
function MainMenu() {
  CHOICE=$(whiptail \
    --title "Checkra1n GUI Installer on $(uname -m)" \
    --menu "Choose an option" $((LINES * 3 / 4)) $((COLUMNS * 7 / 10)) $((LISTHEIGHT)) \
    "Install Repo" "Install the repo. x86_64 ONLY!" \
    "Direct Download" "Use on any architecture." \
    "Procursify" "Install Procursus bootstrap." \
    "Save Blobs" "Save SHSH blobs for up/downgrading." \
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
  "Save Blobs")
    TssSaver
    ;;
  "Credits")
    GetCredits
    ;;
  "Update/Reinstall")
    whiptail --title "Checkra1n GUI Installer" --yesno "Force update to latest version?" $((LINES * 3 / 4)) $((COLUMNS * 7 / 10))
    case $? in
    1)
      MainMenu
      ;;
    0)
      SCRIPT_VERSION=0.0
      ScriptUpdate
      ;;
    esac
    ;;
  esac
}

# Main function. Check script, then checkra1n, then enter the main menu.
ScriptUpdate
Checkra1nChecker
MainMenu
