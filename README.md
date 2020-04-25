# checkra1n-linux
## a simple all-platform checkra1n installer
Works on x86, x86_64, ARM and ARM64!
Tested on: multiple VMs and some RPis
By @randomblock1_

## one liner
download without installing using bash: ```curl -s https://raw.githubusercontent.com/Randomblock1/Checkra1n-Linux/master/installer.sh | sudo bash```
(note: selecting the update option will install it to your machine)

## how to use
Use the "Install Repo" option if you are on x86_64. Otherwise, use "Direct Download", which will install checkra1n to /usr/bin if you tell it to. "Credits" is self explanatory, and "Update" uses wget to get the latest version of this tool. “Install Autostart Service” will automatically start checkra1n on boot. There are 2 options for it: checkra1n and webra1n. Checkra1n will jailbreak your devices automatically with the downside of having to manually put your device into DFU mode (instructions here: https://www.reddit.com/r/jailbreak/wiki/dfumode) before jailbreaking. Webra1n requires you to connect to the device via WiFi or Ethernet. Both of these options cannot be used together because I’m pretty sure checkra1n interferes with other instances of itself.

If you are not on a Debian based system, you may need to install additional dependencies. Just google any errors and see if it means you're missing something.

Please put any issues in the GitHub Issue tracker. Feel free to make pull requests.

## todo
TODO: dynamically fetch the download URLs from the website instead of hardcoding them