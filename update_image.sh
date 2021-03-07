#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

tempdir=$(mktemp -d)
image=$1

if [ ! -e ${image} ]; then
    echo "Missing $image"
    exit 1
fi

if [ ${image: -3} == ".xz" ]; then
    echo -n "Decompressing $image..."
    xz -d $image
    echo "done"
    image=${image%.xz}
    recompress="true"
fi
kpartx="$(kpartx -av $image)"

read -d" " img_boot_dev img_swap_dev img_root_dev <<<$(grep -o 'loop.p.' <<<"$kpartx")
img_boot_dev=/dev/mapper/$img_boot_dev
img_root_dev=/dev/mapper/$img_root_dev

PARTUUID=$(blkid -o export $img_root_dev | awk '/PARTUUID/ { print $1}')

mount -t vfat $img_boot_dev $tempdir
echo -n "cmdline before: "
cat $tempdir/cmdline.txt
grep -q "root=$PARTUUID" $tempdir/cmdline.txt
if [ $? -eq 0 ]; then
    echo "Already modified!"
else
    sed -i "s/root=[^[:space:]]\+/root=$PARTUUID/" $tempdir/cmdline.txt
    sync
fi
echo -n "cmdline after: "
cat $tempdir/cmdline.txt

umount $tempdir
rmdir $tempdir
kpartx -d $image >/dev/null 2>&1

if [ ${recompress}X == "trueX" ]; then
    echo -n "Compressing $image..."
    xz $image
    echo "done"
fi
