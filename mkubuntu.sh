#!/bin/bash
# make sure you're using the alternate image as the Live CD won't work
RELEASE=ubuntu-18.04.2-server-amd64.iso 
MYUSER=$(whoami)
mkdir ubuntu_iso
sudo mount -r -o loop ${RELEASE} ubuntu_iso

mkdir ubuntu_files
rsync -a ubuntu_iso/ ubuntu_files/
sudo chown ${MYUSER}: ubuntu_files
sudo chmod 755 ubuntu_files
sudo umount ubuntu_iso
rm -rf ubuntu_iso

cp {ks.cfg,ubuntu-auto.seed,post.sh} ubuntu_files
chmod 644 ubuntu_files/ks.cfg ubuntu_files/ubuntu-auto.seed
chmod 744 ubuntu_files/post.sh

chmod 755 ubuntu_files/isolinux ubuntu_files/isolinux/txt.cfg ubuntu_files/isolinux/isolinux.cfg

echo "edit ubuntu_files/isolinux/txt.cfg"
echo "
default autoinstall 
label autoinstall
  menu label ^Automatically install Ubuntu
  kernel /install/vmlinuz
  append file=/cdrom/preseed/ubuntu-server.seed vga=788 initrd=/install/initrd.gz ks=cdrom:/ks.cfg preseed/file=/cdrom/ubuntu-auto.seed quiet asknetwork --" > ubuntu_files/isolinux/txt.cfg

sed -i -r 's/timeout\s+[0-9]+/timeout 3/g' ubuntu_files/isolinux/isolinux.cfg


chmod 555 ubuntu_files/isolinux
chmod 444 ubuntu_files/isolinux/txt.cfg ubuntu_files/isolinux/isolinux.cfg

sudo mkisofs -D -r -V "ubuntu-auto" -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -input-charset utf-8 -cache-inodes -quiet -o ubuntu-auto.iso ubuntu_files/

if ! [ -x "$(isohybrid)" ]; then
	echo 'isohybrid not found. trying to install it now'
	sudo apt-get -y install syslinux-utils
fi

isohybrid ubuntu-auto.iso

sudo rm -rf  ubuntu_files
