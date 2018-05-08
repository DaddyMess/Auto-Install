#!/bin/bash

#for the case for program yes or no 
#case $answer in
# Y|y|yes|Yes)
# *) for other options
#Example Locations of Ubuntu ISOs
#http://releases.ubuntu.com/16.04.2/
#http://releases.ubuntu.com/17.04/
#http://releases.ubuntu.com/16.04.2/ubuntu-16.04.2-server-amd64.iso
#http://releases.ubuntu.com/16.04.2/ubuntu-16.04.2-server-i386.iso

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

clear
echo "
...Checking if there is any leftovers from a Previous Install...

..........................Please Wait..........................."
#also create a check for /mnt/iso/md5sum.txt to see if an iso is mounted

if [ -d /opt/serveriso ]; then
echo "Found Serveriso Folder. Removing"
rm -r /opt/serveriso
fi
if [ -d /opt/Auto-Install ]; then
echo "Auto-Install Folder. Removing"
rm -r /opt/Auto-Install
fi
if [ -d /opt/ubuntu-*.iso ]; then
echo "Found ubuntu OS ISO File. Removing"
rm /opt/ubuntu-*.iso
fi
echo "Done.."
sleep 1
clear

echo "Installing Required Programs to Run Iso Script"
sleep 2
apt update
apt install git-core genisoimage mount -y
clear

echo "Fully Automated Script to Download Your Ubuntu ISO, "
echo "Unpack it, edit the MyApps Scripts and then ReImage the ISO back together for you"
#echo " "
#echo "Please only answer questions that are y & n with just y & n "
#echo " "
#echo "What version of Ubuntu?"
#echo "desktop or server?"
#read UbuntuDistro

#echo "What Version of Ubuntu?"
#echo "16.04.3 / 17.04 / Custom Iso?"
#read UbuntuDistroVer

#echo "What bit version of OS?"
#echo "i386(32 bit) or amd64 (64 bit)"
#read UbuntuBit

echo "Downloading Distro"
chmod -R 0777 /opt
wget http://releases.ubuntu.com/16.04.4/ubuntu-16.04.4-server-amd64.iso -P /opt

echo "System Language for the install?"
echo " 'locale' running this Command shows your Current System Setting Format"
echo "ex. en_US is USA English"
read SystemLanguage

echo "Setting up ISO Folder"
mkdir -p /mnt/iso
cd /opt
sudo mount -o loop /opt/ubuntu-16.04.4-server-amd64.iso /mnt/iso
mkdir -p /opt/serveriso
echo "Copying over ISO files"
cp -rT /mnt/iso /opt/serveriso
chmod -R 777 /opt/serveriso/
cd /opt/serveriso

#(to set default/only Language of installer)
echo en_US >isolinux/langlist 
#edit /opt/serveriso/isolinux/txt.cfg  At the end of the append line add ks=cdrom:/ks.cfg. You can remove quiet — and vga=788
sed -i "s#initrd.gz#initrd.gz ks=cdrom:/ks.cfg#" /opt/serveriso/isolinux/txt.cfg
#edit isolinux.cfg for the timeout option to allow a count down to auto start the installer for about 2 seconds
sed -i "s#timeout 0#timeout 10#" /opt/serveriso/isolinux/isolinux.cfg


cd /opt && git clone https://github.com/DaddyMess/Auto-Install.git
cd /opt/Auto-Install

rm README.md
rm _config.yml
cd /opt/serveriso
mv /opt/Auto-Install/ks-example.cfg /opt/serveriso
#####mv /opt/Auto-Install/myapps /opt/serveriso

echo "Setting up KickStart Config File"

echo "Renaming Kickstart Config File"
mv ks-example.cfg ks.cfg

#echo "Setting up Installer Language"
#sed -i "s#en_US#$SystemLanguage#" /opt/serveriso/ks.cfg

#dpkg-reconfigure keyboard-configuration
#echo "System Keyboard Setup ?"
#read SystemKeyboard
#sed -i "s#keyboard us#keyboard $SystemKeyboard#" /opt/serveriso/ks.cfg

#echo "TimeZone ?"
#echo "if dont know the format for your timezone check out:"
#echo "https://en.wikipedia.org/wiki/List_of_tz_database_time_zones"
#read TimeZone
#sed -i "s#America/New_York#$TimeZone#" /opt/serveriso/ks.cfg

#echo "Admin Account UserName ?"
#read AdminUsername
#sed -i "s#xxxusernamexxx#$AdminUsername#g" /opt/serveriso/ks.cfg

#echo "Admin Account Password ?"
#read AdminPassword
#sed -i "s#xxxpasswordxxx#$AdminPassword#" /opt/serveriso/ks.cfg
#RandomSalt=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-8})
#AdminPasswordcrypt=$(openssl passwd -1 -salt $RandomSalt $AdminPassword)

#echo "Is the password already Ubuntu encrypted?"
#read AdminPasswd1
#case $AdminPasswd1 in
#  	n)
#  	echo "Encrypting Paswword"
#  	sed -i "s#$AdminPassword#$AdminPasswordcrypt#g" /opt/serveriso/ks.cfg
#  ;;
#  	*)
#  	;;
#esac

#echo "Swap Partition Size ?"
#echo "Partition Setup Does it under MB NOT AS GB"
#read SwapPartition
#sed -i "s#size 5000#size $SwapPartition#" /opt/serveriso/ks.cfg


#https://www.cyberciti.biz/tips/linux-unix-pause-command.html
#echo "Pausing in Case for extra edits of myapps"
#read -p "Press [Enter] key to Continue"

#echo "What Would You like the Disc Labeled As?"
#read UbuntuLabel
sudo mkisofs -D -r -V "bubu_test" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o /opt/bubu_test.iso /opt/serveriso
sudo chmod -R 777 /opt

echo "Done Creating Custom Ubuntu Server ISO!!!  Enjoy!!!"
