[emulate-pi.sh](emulate-pi.sh) Takes a block device as an argument, treats it as a Raspberry Pi OS image, and attempts to run a shell in a CHROOT via QEMU, so you can do things like install software. Tries to autodetect 32-bit or 64-bit installation, and will work with physical devices (e.g. /dev/sda) and with loop devices (e.g. /dev/loop0). 

If you do want to use a loop device, make sure your losetup program support detection of partitions (the -P flag). For example: 

	losetup -P /dev/loop0 2025-05-13-raspios-bookworm-arm64-lite.img

This will create /dev/loop0 and /dev/loop0p1 as the boot partition, and /dev/loop0p2 as the root partition.

[make-rpi-sdcard.sh](make-rpi-sdcard.sh) Writes a raspbery pi OS image to a block device. Tries to handle different compression formats, and tries to print a percent complete status (although this isn't supported if the compression method doesn't permit access to decompressed file size). Destination could be any block device, not just an SD card.

[backup-rpi-sdcard.sh](backup-rpi-sdcard.sh) Reads a block device (not just an SD card) and creates an compressed archive. If the image name you provide ends with .bz2, .xz, or .zip, it will compress them accordingly.

[mount-img-partitions.sh](mount-img-partitions.sh) ***DEPRECATED*** This attempts to mount an raspberry pi OS image file. It uses loop partitions, but doesn't rely on losetup. Instead it tries to find the offsets in the image file for each partition. There's some logical errors somewhere, so it doesn't get the offsets right. You'd only use it if you don't have a version of losetup that supports the -P flag. This tool doesn't easily work with emulate-pi.sh.

[firstrun.sh](firstrun.sh) ***REFERENCE ONLY*** This is an extract from a custom Raspberry Pi OS image circa June 2024. I keep it as reference to know how rpi-imager automates the customization that it does. DON'T RUN THIS; I've modified it to remove keys and passwords, and if it somehow did run correctly, it would brick your image.
