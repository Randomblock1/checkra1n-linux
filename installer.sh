#!/bin/bash
# Checkra1n Easy Installer
# GitHub Repository: https://github.com/Randomblock1/checkra1n-linux
# shellcheck disable=SC2034,SC1091
VERSION=2.0
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

LINES=$(tput lines)
COLUMNS=$(tput cols)
LISTHEIGHT=$((LINES/3))

# Prints a line with color using terminal codes
Print_Style () {
  printf "%s\n" "${2}$1${NORMAL}"
}

if [ "$BASH_VERSION" = '' ]; then
  whiptail --msgbox "ERROR: this script must be run in bash!" 20 30 --ok-button "Exit"
  exit
fi

if [ "$EUID" -ne 0 ]; then 
  whiptail --msgbox "YOU AREN'T RUNNING AS ROOT! This script needs root, use sudo!" $((LINES/2)) $((COLUMNS*7/10)) --ok-button "Exit"
  Print_Style "ERROR: You need to run this as root, use sudo!" "$RED"
  exit
fi

GetOS () {
# Check system architecture
CPUArch=$(uname -m)
Print_Style "System Architecture: $CPUArch" "$YELLOW"

# Get Linux distribution
# Copied from Stack Overflow lol
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
}

GetOS

GetDependencies () {
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
}

GetDependencies


# get latest checkra1n version number
CHECKRA1NVERSION=$(curl https://checkra.in/ -s | grep "checkra1n .\..*\.." -oE | grep ".\..*\.." -oE)

GetDL () {
Print_Style "Getting latest download..." "$YELLOW"
    # Choose correct download link
    if [[ "$CPUArch" == *"aarch64"* || "$CPUArch" == *"arm64"* ]]; then
      Print_Style "ARM64 detected!" "$YELLOW"
      DL_LINK=$(curl -s https://checkra.in/releases/ | grep "https:\/\/assets.checkra.in\/downloads\/linux\/cli\/arm64\/.*\/checkra1n" -o)
  
    elif [[ "$CPUArch" == *"armhf"* || "$CPUArch" == *"armv"* ]]; then
      Print_Style "ARM detected!" "$YELLOW"
      DL_LINK=$(curl -s https://checkra.in/releases/ | grep "https:\/\/assets.checkra.in\/downloads\/linux\/cli\/arm\/.*\/checkra1n" -o)
  
    elif [[ "$CPUArch" == *"x86_64"* ]]; then
      Print_Style "x86_64 detected!" "$YELLOW"
      DL_LINK=$(curl -s https://checkra.in/releases/ | grep "https:\/\/assets.checkra.in\/downloads\/linux\/cli\/x86_64\/.*\/checkra1n" -o)

    elif [[ "$CPUArch" == *"x86"* ]]; then
      Print_Style "x86 detected!" "$YELLOW"
      DL_LINK=$(curl -s https://checkra.in/releases/ | grep "https:\/\/assets.checkra.in\/downloads\/linux\/cli\/i486\/.*\/checkra1n" -o)
    else
      Print_Style "ERROR: Unknown/Unsupported architecture! Make sure your architecture is supported by checkra1n." "$RED"
      DL_LINK=UNKNOWN
      exit
    fi
}

ScriptUpdate () {
  ONLINE_"$(curl -s https://raw.githubusercontent.com/Randomblock1/checkra1n-linux/master/installer.sh | head -n 4 | grep VERSION)"
  if [ "$ONLINE_VERSION" != "$VERSION" ]; then
  Print_Style "Updating..." "$GREEN"
      mkdir checkra1n-linux
      (
      cd checkra1n-linux || exit
      wget https://raw.githubusercontent.com/Randomblock1/checkra1n-linux/master/installer.sh
      chmod 755 ./*.sh
      mv -f ./* ..
      )
      rm -R checkra1n-linux
      Print_Style "Completed!" "$GREEN"
      whiptail --title "Script Updated" --msgbox "This script has been automatically updated to version $ONLINE_VERSION!" $((LINES/2)) $((COLUMNS*7/10))
     ./installer.sh
  else
  Print_Style "Script is already up to date!" "$GREEN"
  fi
}

GetJB () {
  Print_Style "Getting checkra1n..." "$GREEN"
  curl "$DL_LINK" -o /usr/bin/checkra1n
  chmod 755 /usr/bin/checkra1n
}

Checkra1nChecker () {
if ! test "$HOME/.cache"; then
  mkdir ~/.cache
fi
if test -f ~/.cache/checkra1n-version; then
  INSTALLEDVERSION=$(cat ~/.cache/checkra1n-version)
  if [ "$CHECKRA1NVERSION" != "$INSTALLEDVERSION" ]; then
    if (whiptail --title "Checkra1n Update" --yesno "An update for checkra1n is available ($(cat ~/.cache/checkra1n-version) to $CHECKRA1NVERSION). Update?" $((LINES/2)) $((COLUMNS*7/10))); then
    UpdateCheckra1n
    fi
  else
    Print_Style "Checkra1n is up to date!" "$GREEN"
  fi
else
  if test -f /usr/bin/checkra1n; then
    echo "$CHECKRA1NVERSION" > ~/.cache/checkra1n-version
  else
    echo 0.00.0 > ~/.cache/checkra1n-version
  fi
fi
}


DirectDL () {
GetOS
GetDependencies    
GetDL
GetJB
Print_Style "Done! Marked as executable!" "$GREEN"
Print_Style "All done!" "$BLINK"
}

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

function MainMenu() {
  CHOICE=$(whiptail \
  --title "Checkra1n GUI Installer on $(uname -m)" \
  --menu "Choose an option" $((LINES/2)) $((COLUMNS*7/10)) $((LISTHEIGHT)) \
    "Install Repo" "Install the repo. x86_64 ONLY!" \
    "Direct Download" "Use on any architecture." \
    "Install Autostart Service" "Automatically start checkra1n on boot." \
    "Credits" "This tool is open-source!" \
    "Update/Reinstall" "Update this tool" 3>&1 1>&2 2>&3)
  case $CHOICE in
    "Install Repo")
    InstallRepo
    ;;
    "Direct Download")
    DirectDL
    ;;
    "Install Autostart Service")
    CHOICE=$(whiptail \
  --title "Checkra1n Service Installer on $(uname -m)" \
  --menu "Choose ONE OR THE OTHER. Having them both working is not possible since they interfere with each other (i think?)." $((LINES/2)) $((COLUMNS*7/10)) $((LISTHEIGHT)) \
    "Install Automatic checkra1n" "Automatically jailbreaks DFU devices." \
    "Install Automatic webra1n" "Starts webra1n on port 8081." 3>&1 1>&2 2>&3)
    case $CHOICE in
    "Install Automatic checkra1n")
      if whiptail --yesno "Install autostart service? This requires you to put your device into DFU mode manually it to work." $((LINES/2)) $((COLUMNS*7/10)) $((LISTHEIGHT)); then
        wget -O checkra1n-linux.service https://raw.githubusercontent.com/Randomblock1/Checkra1n-Linux/master/checkra1n-linux.service
        chmod 644 checkra1n-linux.service
        mv checkra1n-linux.service /lib/systemd/system/checkra1n-linux.service
        Print_Style "Moved service to /lib/systemd/system/" "$GREEN"
        Print_Style "Enabling service..." "$GREEN"
        systemctl daemon-reload
        systemctl enable checkra1n-linux
        systemctl restart checkra1n-linux
        Print_Style "Success!"$ "$GREEN"
        whiptail --title "Using Checkra1n Autostart Service" --msgbox "This installation is now configured to autostart checkra1n on boot. \nThis means that your device must be in DFU mode manually in order to jailbreak. The autostart service may also interfere with other instances of checkra1n and cause them to fail. \nInstructions of how to put your device into DFU mode are here: \nhttps://www.reddit.com/r/jailbreak/wiki/dfumode \nPlug your device in, push some buttons, and checkra1n will do its work."
      fi
      MainMenu
      ;;
      "Install Automatic webra1n")
      if whiptail --yesno "Install autostart service? This requires you to use a web browser on a different device to jailbreak." $((LINES/2)) $((COLUMNS*7/10)) $((LISTHEIGHT)); then
        wget -O checkra1n-linux.service https://raw.githubusercontent.com/Randomblock1/Checkra1n-Linux/master/checkra1n-linux-webra1n.service
        chmod 644 checkra1n-linux.service
        mv checkra1n-linux.service /lib/systemd/system/checkra1n-linux.service
        Print_Style "Moved service to /lib/systemd/system/" "$GREEN"
        Print_Style "Enabling service..." "$GREEN"
        systemctl daemon-reload
        systemctl enable checkra1n-linux
        systemctl restart checkra1n-linux
        Print_Style "Success!"$ "$GREEN"
        NET_IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -1)
        whiptail --title "Using Checkra1n Autostart Service" --msgbox "This installation is now configured to autostart webra1n on boot. \nThis means that you must use a web browser and access this device's local IP via WiFi or Ethernet at port 8081. \nCurrent local URL: \n$NET_IP:8081/ \nNote: this will change if the device connects to a different network or loses connection."
      fi
      MainMenu
    esac
    ;;
    "Credits")
    NET_IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -1)
    whiptail --title "Checkra1n GUI Installer" --msgbox "Checkra1n GUI Installer made by Randomblock1.\nThis project is open source! Check out https://github.com/Randomblock1/Checkra1n-Linux! \nFollow me on Twitter @randomblock1_! \nPlease report all bugs in the GitHub issue tracker and feel free to make pull requests! \nINFO: $OS $(uname -mo) \nVERSION: $VERSION \nLocal IP: $NET_IP" $((LINES/2)) $((COLUMNS*7/10)) $((LISTHEIGHT))
    MainMenu
    ;;
    "Update/Reinstall")
    whiptail --title "Checkra1n GUI Installer" --yesno "Update to latest version?" $((LINES/2)) $((COLUMNS*7/10))
    case $? in
      1)
      MainMenu
      ;;
      0)
      ScriptUpdate
   esac
  esac
}

ScriptUpdate
Checkra1nChecker
MainMenu
