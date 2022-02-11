#!/bin/bash -xv

set -eo pipefail

LOOP="/dev/loop7"
ROOT="/dev/loop7p1"

VERSION="2022.2-1"
if [ "$1" != "" ]; then
    VERSION="$1"
fi

sudo umount root || true
sudo losetup -d $LOOP || true

sudo rm -fR root gkiss-chroot* gkiss.img
mkdir root

wget https://github.com/gkisslinux/grepo/releases/download/${VERSION}/gkiss-chroot-${VERSION}.tar.xz

wget https://github.com/gkisslinux/grepo/releases/download/${VERSION}/gkiss-chroot-${VERSION}.tar.xz.sha256
sha256sum -c < gkiss-chroot-${VERSION}.tar.xz.sha256

dd if=/dev/zero of=gkiss.img bs=1G count=8

fdisk gkiss.img <<EOF
o
n
p
1


a
w
EOF

sudo losetup -v -P $LOOP gkiss.img
sudo mkfs.ext4 $ROOT
sudo mount $ROOT root

sudo tar xf gkiss-chroot-${VERSION}.tar.xz -C root --strip-components 1

sudo cp stage2.sh root/

echo "Run ./stage2.sh in the chroot..."

sudo root/bin/gkiss-chroot ./root

sudo umount root
sudo losetup -d $LOOP

echo "Success!"
