# ansible-shairport

Ansible playbooks for setting up shairport sync on an Raspberry pi running CentOS 8 Stream

## Getting the Image
```
% curl -O https://people.centos.org/pgreco/CentOS-Userland-8-stream-aarch64-RaspberryPI-Minimal-4/CentOS-Userland-8-stream-aarch64-RaspberryPI-Minimal-4-sda.raw.xz
```
## Updating the Image
If you are using usb to boot the image instead of an sdcard you will need to update the image since it defaults to booting from /dev/mmcblk0.  The update_image.sh script will extract the image and update the cmdline.txt file to point the root entry to the PARTUUID so it will work for both sdcard and usb.  If you will only ever use the sdcard you can skip this step.
```
% sudo ./update_image.sh CentOS-Userland-8-stream-aarch64-RaspberryPI-Minimal-4-sda.raw.xz
Decompressing CentOS-Userland-8-stream-aarch64-RaspberryPI-Minimal-4-sda.raw.xz...done
cmdline before: console=ttyAMA0,115200 console=tty1 root=/dev/mmcblk0p3 rootfstype=ext4 elevator=deadline rootwait
cmdline after: console=ttyAMA0,115200 console=tty1 root=PARTUUID=68bafdb3-03 rootfstype=ext4 elevator=deadline rootwait
Compressing CentOS-Userland-8-stream-aarch64-RaspberryPI-Minimal-4-sda.raw...done
```

## Writing the Image
You can write the image to your sdcard or usb drive for use in the raspberry pi by using the dd command.  Replace [BLOCK] with the appropriate device that the sdcard or usb drive has showed up as.  Please be very careful here to specify this correctly since you will overwrite any data on that device. On my system this is /dev/sdb, it may also be /dev/mmcblk0.
```
% xzcat CentOS-Userland-8-stream-aarch64-RaspberryPI-Minimal-4-sda.raw.xz | sudo dd of=[BLOCK] bs=1M status=progress
```

## Updating the Inventory file
```
% cp hosts.example hosts
% vi hosts
```

## Running the playbook
```
% ssh-copy-id root@RPI-HOSTNAME
% ansible-playbook -i hosts playbook.yml
```
