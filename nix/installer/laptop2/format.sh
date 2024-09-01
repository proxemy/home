#!/usr/bin/bash
set -xeuo pipefail

DEV="/dev/sda"

partx --show "$DEV"

echo "Partitioning disc: '$DEV'! All data will be lost!"
read -p "Proceed? [y/N]:" confirm
[[ "$confirm" =~ y|Y ]] || { echo "Arborting"; exit 0; }

wipefs "$DEV"
parted -s "$DEV" mklabel msdos

parted -s "$DEV" -- mkpart primary 1MB -16GB
parted -s "$DEV" -- set 1 boot on
parted -s "$DEV" -- mkpart primary linux-swap -16GB 100%

mkfs.ext4 -L nixos "$DEV"1
mkswap -L swap "$DEV"2

mount /dev/disk/by-label/nixos /mnt
swapon /dev/disk/by-label/swap


# TODO create dedicated setup.sh and install.sh with the content below
# TODO create shellcheck flake tests for all .sh files
HOMEDIR=/mnt/etc/nixos/home

git init --initial-branch=main "$HOMEDIR"
cd "$HOMEDIR"
git-crypt unlock /iso/git-crypt-key-file
git --work-tree="$HOMEDIR" --git-dir="$HOMEDIR"/.git remote add origin "https://github.com/proxemy/home"
git --work-tree="$HOMEDIR" --git-dir="$HOMEDIR"/.git pull --set-upstream origin main
#cp -r /iso/flake-sourceInfo/* "$HOMEDIR"

nixos-install --flake /mnt/etc/nixos/home#laptop2 --root /mnt --verbose
