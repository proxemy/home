#!/usr/bin/bash
set -euo pipefail

DEV="/dev/sda"
HOMEDIR="/mnt/${1:-$ARG_1_HOMEDIR_NOT_SET}"
test -b "$DEV" || { echo "\$DEV '$DEV' is not a block device"; exit 1; }

partx --show "$DEV"

echo "Partitioning disc: '$DEV'! All data will be lost!"
read -p "Proceed? [y/N]:" confirm
[[ "$confirm" =~ y|Y ]] || { echo "Arborting"; exit 0; }

set -x

wipefs "$DEV"
parted -s "$DEV" mklabel msdos

parted -s "$DEV" -- mkpart primary 1MB -16GB
parted -s "$DEV" -- set 1 boot on
parted -s "$DEV" -- mkpart primary linux-swap -16GB 100%

mkfs.ext4 -L nixos "$DEV"1
mkswap -L swap "$DEV"2

mount /dev/disk/by-label/nixos /mnt
swapon /dev/disk/by-label/swap

# TODO create shellcheck flake tests for all .sh files

mkdir -p "$HOMEDIR"
cp -r /iso/home-git/. "$HOMEDIR"

nixos-install \
  --flake "$HOMEDIR"#$(hostname) \
	--root /mnt \
	--no-root-passwd \
	--verbose \
	--show-trace
