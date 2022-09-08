#!/bin/zsh
set -e
echo "path: $PATH"
if [ $(uname -p) = "arm" ] || [ $(uname -p) = "arm64" ]; then
	ARM=yes
fi
if [[ ! "${ARM}" = yes ]]; then
	cd /var/root
fi
if [[ -f "/.bootstrapped" ]]; then
	mkdir -p /odyssey && mv migration /odyssey
	chmod 0755 /odyssey/migration
	/odyssey/migration
	rm -rf /odyssey
else
	VER=$(/binpack/usr/bin/plutil -key ProductVersion /System/Library/CoreServices/SystemVersion.plist)
	if [[ "${VER%.*}" -ge 12 ]] && [[ "${VER%.*}" -lt 13 ]]; then
		CFVER=1500
	elif [[ "${VER%.*}" -ge 13 ]]; then
		CFVER=1600
	elif [[ "${VER%.*}" -ge 14 ]]; then
		CFVER=1700
	else
		echo "${VER} not compatible."
		exit 1
	fi
	gzip -d bootstrap_${CFVER}.tar.gz
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
	tar --preserve-permissions -xkf bootstrap_${CFVER}.tar -C /
	SNAPSHOT=$(snappy -s | cut -d ' ' -f 3 | tr -d '\n')
	snappy -f / -r $SNAPSHOT -t orig-fs
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
if [[ $VER = 12.1* ]] || [[ $VER = 12.0* ]]; then
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
