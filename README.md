# Collection of scripts and reference configs for setting up OS and software on a Raspberry Pi 

[backup-rpi-sdcard.sh](backup-rpi-sdcard.sh) Reads a block device (not just an SD card) and creates an compressed archive. If the image name you provide ends with .bz2, .xz, or .zip, it will compress them accordingly.

[emulate-pi.sh](emulate-pi.sh) Takes a block device as an argument, assumes it is a Raspberry Pi OS image, and attempts to run a shell via QEMU in `chroot`, so you can do things like install software or change settings. It's not a VM, just a ARM process running under instruction emulation. Tries to autodetect 32-bit or 64-bit installations, and will work with physical devices (e.g. `/dev/sda`) and with loop devices (e.g. `/dev/loop0`). 

If you do want to use a loop device, make sure your `losetup` program support detection of partitions (the -P flag). For example: 

	losetup -P /dev/loop0 2025-05-13-raspios-bookworm-arm64-lite.img

This will create `/dev/loop0`, with `/dev/loop0p1` as the boot partition and `/dev/loop0p2` as the root partition.

This will run on amd64/x86, and it will also run under ARM aarch64, but unfortunately you cannot run 32-bit processes under 64-bit kernel.

[etc-NetworkManager-system-connections-aptsec.nmconnection](etc-NetworkManager-system-connections-aptsec.nmconnection) ***REFERENCE ONLY*** This is an extract from an RPi with a configured Wi-Fi interface. RPi OS doesn't seem to use `wpa_supplicant` anymore (except maybe it does sometimes? I can't tell). So I keep this as reference for how NetworkManager (the abomination) stores its configuration. If you replace the dashes in the file name with slashes, you'll know where to find this file. I've replaced the sensitive information from this file. You need to set id, ssid, and wpa_psk.

[firstrun.sh](firstrun.sh) ***REFERENCE ONLY*** This is an extract from a custom Raspberry Pi OS image circa June 2024. I keep it as reference to know how rpi-imager automates the customization that it does. DON'T RUN THIS; I've modified it to remove keys and passwords, and if it somehow did run correctly, it would brick your image.

[make-rpi-sdcard.sh](make-rpi-sdcard.sh) Writes a Raspbery Pi OS image to a block device. Tries to handle different compression formats, and tries to print a percent complete status (although this isn't supported if the compression method doesn't permit access to decompressed file size). Destination could be any block device, not just an SD card.

[mount-img-partitions.sh](mount-img-partitions.sh) ***DEPRECATED*** This attempts to mount a Raspberry Pi OS image file. It uses loop partitions, but doesn't rely on `losetup`. Instead it tries to find the offsets in the image file for each partition. There's some logical or math errors somewhere, so it doesn't get the offsets right. You'd only use it if you don't have a version of `losetup` that supports the `-P` flag. This tool doesn't easily work with `emulate-pi.sh`, because both attempt to handle mounting of the partitions.

[new-ssh-keys-for-image](new-ssh-keys-for-image) This will generate new SSH server keys. I haven't used it in a while, so I'm not sure if it's compatible with recent SSHD default configurations. But it's a start. Intention is to use this when you are duplicating an existing RPi OS image, and want to make unique SSHD keys. Intended to be used with `emulate-pi.sh`.


