# checkra1n-linux
## a simple all-platform checkra1n installer
Works on x86, x86_64, ARM and ARM64!
Tested on: multiple VMs and some RPis
By @randomblock1_

## one liner
download without installing using bash: ```curl -s https://raw.githubusercontent.com/Randomblock1/Checkra1n-Linux/master/installer.sh | sudo bash```
(note: selecting the update option will install it to your machine)

## how to use
Use the "Install Repo" option if you are on x86_64. Otherwise, use "Direct Download". "Credits" is self explanatory, and "Update" uses git to get the latest version of this tool and installs it.

If you are not on a Debian based system, you may need to install additional dependencies. Just google any errors and see if it means you're missing something.

Please put any issues in the GitHub Issue tracker. Feel free to make pull requests.

## todo
TODO: dynamically fetch the download URLs from the website instead of hardcoding them