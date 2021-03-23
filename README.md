# checkra1n-linux
## a simple all-platform checkra1n installer
Works on x86, x86\_64, ARM and ARM64!
Tested on: multiple VMs and some RPis
By @randomblock1\_

## one liner
download without installing using bash:
`curl -s https://raw.githubusercontent.com/Randomblock1/Checkra1n-Linux/master/installer.sh | sudo bash`
(note: this won't install it to your machine)


## how to use
- "Install Repo"
  - This will install the checkra1n APT repo, but only if you are using x86\_64.
- "Direct Download"
  - Installs checkra1n to /usr/bin for all devices, even non x86\_64.
- "Procursify"
  - Installs the Procursus bootstrap to your device. Learn more about Procursus [here](https://github.com/ProcursusTeam/Procursus). TLDR: Replaces Substrate with libhooker and uses the Procursus repo for more up-to-date programs. Also, you get Sileo, in addition to Cydia.
- “Save Blobs”
  - Saves signed SHSH blobs so you can upgrade/downgrade to unsigned iOS versions if you have the right blobs.
- "Credits"
  - Is self explanatory
- "Update"
  - Uses curl to get the latest version of this tool.

If you are not on a Debian based system, you may need to install dependencies manually. Just Google any errors and see if it means you're missing something.

Please put any issues in the GitHub Issue tracker and feel free to make pull requests.

## todo
add support for systems that are not Debian or OSX
