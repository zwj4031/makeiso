#!/bin/sh
find | cpio -H newc -o | xz --threads=8 --check=crc32 --x86 --lzma2 > /mnt/s/netgrubfm/initrd.xz