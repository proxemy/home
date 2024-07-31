#!/usr/bin/env bash

set -xeuo pipefail

# nix-shell -p nixos-generators --run "nixos-generate --format iso --configuration ./raspi-image.nix -o result"

nixos-generate --flake .#laptop2 --format iso --out-link result
ISO="result/iso/nixos-24.11.20240725.5ad6a14-x86_64-linux.iso"
test -f "$ISO"

sudo umount /dev/sda* || true
sudo dd if="$ISO" of=/dev/sda status=progress
sync
sudo umount /dev/sda*
sudo rm /dev/sda*
# sync

