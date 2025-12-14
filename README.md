# ironic-esp

ESP UEFI Image Builder for OpenStack Ironic

## Overview

This repository contains tools to build an ESP (EFI System Partition) UEFI image for use with OpenStack Ironic. The image is designed to support the Ironic DIB (Disk Image Builder) files that are prebuilt and available at https://tarballs.opendev.org/openstack/ironic-python-agent/dib/files/ in a UEFI environment that uses virtual media boot with ISO generation.

## Features

- **CentOS Stream 9 based**: Built using official CentOS Stream 9 bootloader packages
- **Secure Boot Support**: Uses signed shim and grub2 bootloaders for UEFI Secure Boot compatibility
- **Automated Builds**: GitHub Actions workflow for automated building and releasing
- **Small footprint**: 3MB FAT12 formatted image

## Building the Image

### Prerequisites

To build the ESP image locally, you need a CentOS Stream 9 environment (physical machine, VM, or container) with the following packages installed:

```bash
sudo dnf install -y dosfstools mtools shim-x64 grub2-efi-x64
```

### Building

Simply run the build script:

```bash
./build-centos9-esp.sh
```

This will create an `esp-centos9.img` file in the current directory.

### What the Script Does

1. Creates a 3MB empty file
2. Formats it as FAT12 filesystem
3. Creates the EFI directory structure (`EFI/BOOT`)
4. Copies the signed shim bootloader as `BOOTX64.EFI` (required by UEFI spec)
5. Copies the grub2 bootloader as `grubx64.efi` (chainloaded by shim)

## Automated Releases

The repository includes a GitHub Actions workflow that automatically:

1. Builds the ESP image in a CentOS Stream 9 container
2. Uploads the image as an artifact
3. Creates a GitHub release with the image (when triggered by a version tag)

### Triggering a Release

To create a new release:

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

You can also manually trigger the workflow from the GitHub Actions tab.

## Usage with Ironic

The generated `esp-centos9.img` can be used with OpenStack Ironic for UEFI virtual media boot. This is particularly useful when using prebuilt Ironic Python Agent images in environments that require Secure Boot support.

## Technical Details

- **Image Size**: 3MB
- **Filesystem**: FAT12
- **Bootloader Chain**: UEFI Firmware → shimx64.efi (as BOOTX64.EFI) → grubx64.efi
- **Secure Boot**: Supported via Red Hat/CentOS signed bootloaders

## License

This project is provided as-is for use with OpenStack Ironic deployments.
