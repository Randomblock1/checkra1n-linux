# checkra1n-linux
## a simple all-platform checkra1n installer
Works on x86, x86\_64, ARM and ARM64!
Tested on: multiple VMs and some RPis
By @randomblock1\_

## one liner
download without installing using bash:
```curl -s https://raw.githubusercontent.com/Randomblock1/Checkra1n-Linux/master/installer.sh | sudo bash```
(note: this won't install it to your machine)

Optionally, instead of that long githubusercontent URL, you can use this: [https://git.io/JTA0p](https://git.io/JTA0p). It's GitHub's own link shortener. It would look like this: ```curl -s https://git.io/JTA0p | sudo bash```

## how to use
Use the "Install Repo" option if you are on x86\_64. Otherwise, use "Direct Download", which will install checkra1n to /usr/bin.
"Procursify" will install the Procursus bootstrap to your device. Learn more about Procursus [here](https://github.com/ProcursusTeam/Procursus). TLDR: Replaces Substrate with libhooker (supposedly better) and uses the Procursus repo for more up-to-date programs. Also, you get Sileo.
"Credits" is self explanatory, and "Update" uses curl to get the latest version of this tool.

If you are not on a Debian based system, you may need to install additional dependencies. Just Google any errors and see if it means you're missing something.

Please put any issues in the GitHub Issue tracker and feel free to make pull requests.

## todo
add support for non-Debian systems

unprocursify

fix startup scripts
