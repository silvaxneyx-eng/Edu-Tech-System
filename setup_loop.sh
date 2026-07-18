#!/bin/bash
mknod -m 0660 /dev/loop-control c 10 237 2>/dev/null
for i in {0..7}; do
    mknod -m 0660 /dev/loop$i b 7 $i 2>/dev/null
done
losetup -f
chroot /home/jardson/fedora-bootstrap bash -c 'cd /build && livecd-creator --verbose --config=fedora-live-tecnico.ks --fslabel=ISO_LOUCA_BOOT'
