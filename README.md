# checkra1n-linux
## a simple all-platform checkra1n installer
Works on x86, x86_64, ARM and ARM64!
Tested on: multiple VMs and some RPis
By @randomblock1_

## how to use
Installer.sh is probably the best script for you. Simply run ```./installer.sh``` in bash. If you are on a Debian based system *and* running x86_64, use the "install repo" option in the GUI. This will install the repo and install checkra1n from that repo.

If you are on any other system or any other architecture, use "direct download" in the GUI. This downloads the correct binary and lets you put it in /usr/bin. The repo only contains x86_64 files, which is why this script is needed.

Please put any issues in the GitHub Issue tracker. Feel free to make pull requests.

## TODO
TODO: dynamically fetch the download URLs from the website instead of hardcoding them