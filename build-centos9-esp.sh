#!/bin/bash
set -e -u

# --- Configuration ---
OUTPUT_IMG="esp-centos9.img"
# On CentOS 9, installing the packages usually places binaries here:
SRC_SHIM="/boot/efi/EFI/centos/shimx64.efi"
SRC_GRUB="/boot/efi/EFI/centos/grubx64.efi"

# Verify files exist before proceeding
if [ ! -f "$SRC_SHIM" ] || [ ! -f "$SRC_GRUB" ]; then
    echo "Error: Bootloader binaries not found."
    echo "Please run: dnf install -y shim-x64 grub2-efi-x64"
    exit 1
fi

echo "Building $OUTPUT_IMG..."

# 1. Create a 3MB empty file
dd if=/dev/zero of="$OUTPUT_IMG" bs=1M count=3 status=none

# 2. Format as FAT12 (Standard for small ESP images)
mkfs.msdos -F 12 -n 'ESP_IMAGE' "$OUTPUT_IMG" > /dev/null

# 3. Create EFI directories
mmd -i "$OUTPUT_IMG" ::EFI
mmd -i "$OUTPUT_IMG" ::EFI/BOOT

# 4. Copy and Rename Binaries
#    The UEFI spec requires the default bootloader to be named BOOTX64.EFI.
#    We rename the 'shim' to BOOTX64.EFI so the BIOS loads it first.
echo "Copying shim ($SRC_SHIM) -> ::EFI/BOOT/BOOTX64.EFI"
mcopy -i "$OUTPUT_IMG" "$SRC_SHIM" ::EFI/BOOT/BOOTX64.EFI

#    The shim will look for 'grubx64.efi' in the same directory to chainload.
echo "Copying grub ($SRC_GRUB) -> ::EFI/BOOT/grubx64.efi"
mcopy -i "$OUTPUT_IMG" "$SRC_GRUB" ::EFI/BOOT/grubx64.efi

echo "Success! $OUTPUT_IMG is ready."
