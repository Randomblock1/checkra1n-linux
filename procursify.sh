#!/bin/bash
# shellcheck disable=SC2162
set -e

Print_Style() {
	printf "%s\n" "${2}$1${NORMAL}"
}

NORMAL=$(tput sgr0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
CYAN=$(tput setaf 6)
BRIGHT=$(tput bold)
REVERSE=$(tput smso)

if [[ $1 = -y ]]; then
	AUTO=yes
fi

if [ "$(uname)" = "Darwin" ]; then
	product=$(sw_vers -productName 2>/dev/null)
	if [ "$product" != "macOS" ] && [ "$product" != "Mac OS X" ]; then
		echo "It's recommended this script be ran on macOS/Linux with a clean iOS device running checkra1n attached unless migrating from older bootstrap."
		if [[ $AUTO != yes ]]; then
			read -p "Press enter to continue"
		fi
		ARM=yes
	fi
fi

echo ""
Print_Style "Before you begin: This script includes experimental migration from older bootstraps to Procursus/Odyssey." "$BRIGHT"
Print_Style "If you're already jailbroken, you can run this script on the checkra1n device." "$GREEN"
Print_Style "If you'd rather start clean, please Reset System via the Loader app first." "$RED"

if [[ $AUTO != yes ]]; then
	read -p "Press enter to continue"
fi

echo "Please connect your device to your computer and trust it."
if [[ $AUTO != yes ]]; then
	read -p "Press enter to continue"
fi

if ! which curl >>/dev/null; then
	Print_Style "Error: curl not found" "$RED"
	exit 1
fi
if [[ "${ARM}" = yes ]]; then
	if ! which zsh >>/dev/null; then
		Print_Style "Error: zsh not found" "$RED"
		exit 1
	fi
else
	if which iproxy >>/dev/null; then
		iproxy 42264 44 >>/dev/null 2>/dev/null &
		trap 'killall iproxy 2>/dev/null' ERR
	else
		Print_Style "Error: iproxy not found" "$RED"
		exit 1
	fi

	if [[ -z $SSHPASS ]]; then
		read -s -p "Enter the root password (default is 'alpine'): " SSHPASS
		echo
	fi
	if [[ $SSHPASS = "" ]]; then
		SSHPASS=alpine
	fi
fi
rm -rf odyssey-tmp
mkdir odyssey-tmp
cd odyssey-tmp

cat >odyssey-device-deploy.sh <<EOT
#!/bin/zsh
set -e
echo "path: \$PATH"
if [ \$(uname -p) = "arm" ] || [ \$(uname -p) = "arm64" ]; then
	ARM=yes
fi
if [[ ! "\${ARM}" = yes ]]; then
	cd /var/root
fi
if [[ -f "/.bootstrapped" ]]; then
	mkdir -p /odyssey && mv migration /odyssey
	chmod 0755 /odyssey/migration
	/odyssey/migration
	rm -rf /odyssey
else
	VER=\$(/binpack/usr/bin/plutil -key ProductVersion /System/Library/CoreServices/SystemVersion.plist)
	if [[ "\${VER%.*}" -ge 12 ]] && [[ "\${VER%.*}" -lt 13 ]]; then
		CFVER=1500
	elif [[ "\${VER%.*}" -ge 13 ]]; then
		CFVER=1600
	elif [[ "\${VER%.*}" -ge 14 ]]; then
		CFVER=1700
	else
		echo "\${VER} not compatible."
		exit 1
	fi
	gzip -d bootstrap_\${CFVER}.tar.gz
	mount -uw -o union /dev/disk0s1s1
	rm -rf /etc/profile
	rm -rf /etc/profile.d
	rm -rf /etc/alternatives
	rm -rf /etc/apt
	rm -rf /etc/ssl
	rm -rf /etc/ssh
	rm -rf /etc/dpkg
	rm -rf /Library/dpkg
	rm -rf /var/cache
	rm -rf /var/lib
	tar --preserve-permissions -xkf bootstrap_\${CFVER}.tar -C /
	SNAPSHOT=\$(snappy -s | cut -d ' ' -f 3 | tr -d '\n')
	snappy -f / -r \$SNAPSHOT -t orig-fs
fi
/usr/libexec/firmware
mkdir -p /etc/apt/sources.list.d/
echo "Types: deb" > /etc/apt/sources.list.d/odyssey.sources
echo "URIs: https://repo.theodyssey.dev/" >> /etc/apt/sources.list.d/odyssey.sources
echo "Suites: ./" >> /etc/apt/sources.list.d/odyssey.sources
echo "Components: " >> /etc/apt/sources.list.d/odyssey.sources
echo "" >> /etc/apt/sources.list.d/odyssey.sources
mkdir -p /etc/apt/preferences.d/
echo "Package: *" > /etc/apt/preferences.d/odyssey
echo "Pin: release n=odyssey-ios" >> /etc/apt/preferences.d/odyssey
echo "Pin-Priority: 1001" >> /etc/apt/preferences.d/odyssey
echo "" >> /etc/apt/preferences.d/odyssey
if [[ \$VER = 12.1* ]] || [[ \$VER = 12.0* ]]; then
	PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11:/usr/games dpkg -i org.swift.libswift_5.0-electra2_iphoneos-arm.deb
fi
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11:/usr/games dpkg -i org.coolstar.sileo_2.0.0b6_iphoneos-arm.deb org.coolstar.libhooker_1.4.0_iphoneos-arm.deb org.coolstar.safemode_1.1.2-2_iphoneos-arm.deb
uicache -p /Applications/Sileo.app
echo -n "" > /var/lib/dpkg/available
/Library/dpkg/info/profile.d.postinst
touch /.mount_rw
touch /.installed_odyssey
rm bootstrap*.tar*
rm migration
rm org.coolstar.sileo_2.0.0b6_iphoneos-arm.deb
rm org.swift.libswift_5.0-electra2_iphoneos-arm.deb
rm org.coolstar.libhooker_1.4.0_iphoneos-arm.deb
rm org.coolstar.safemode_1.1.2-2_iphoneos-arm.deb
/etc/rc.d/libhooker
rm odyssey-device-deploy.sh
EOT

Print_Style "Downloading Resources..." "$GREEN $REVERSE"
curl -#L -O https://github.com/coolstar/odyssey-bootstrap/raw/master/bootstrap_1500.tar.gz \
	-O https://github.com/coolstar/odyssey-bootstrap/raw/master/bootstrap_1600.tar.gz \
	-O https://github.com/coolstar/odyssey-bootstrap/raw/master/bootstrap_1700.tar.gz \
	-O https://github.com/coolstar/odyssey-bootstrap/raw/master/migration \
	-O https://github.com/coolstar/odyssey-bootstrap/raw/master/org.coolstar.sileo_2.0.0b6_iphoneos-arm.deb \
	-O https://github.com/coolstar/odyssey-bootstrap/raw/master/org.swift.libswift_5.0-electra2_iphoneos-arm.deb \
	-O https://repo.theodyssey.dev/debs/org.coolstar.libhooker_1.4.0_iphoneos-arm.deb \
	-O https://repo.theodyssey.dev/debs/org.coolstar.safemode_1.1.2-2_iphoneos-arm.deb
if [[ ! "${ARM}" = yes ]]; then
	Print_Style "Copying Files to your device" "$GREEN $REVERSE"
	sshpass -e scp -P42264 -o "StrictHostKeyChecking no" -o "UserKnownHostsFile=/dev/null" \
		bootstrap_1500.tar.gz \
		bootstrap_1600.tar.gz \
		bootstrap_1700.tar.gz \
		migration \
		org.coolstar.sileo_2.0.0b6_iphoneos-arm.deb \
		org.swift.libswift_5.0-electra2_iphoneos-arm.deb \
		org.coolstar.libhooker_1.4.0_iphoneos-arm.deb \
		org.coolstar.safemode_1.1.2-2_iphoneos-arm.deb \
		odyssey-device-deploy.sh \
		root@127.0.0.1:/var/root/
fi
Print_Style "Installing Procursus bootstrap and Sileo on your device" "$GREEN $REVERSE"
if [[ "${ARM}" = yes ]]; then
	zsh ./odyssey-device-deploy.sh
else
	sshpass -e ssh -p42264 -o "StrictHostKeyChecking no" -o "UserKnownHostsFile=/dev/null" root@127.0.0.1 "zsh /var/root/odyssey-device-deploy.sh"
	Print_Style "All Done!" "$CYAN $REVERSE"
	killall iproxy
fi
