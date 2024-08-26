#!/usr/bin/env bash

set -xeuo pipefail

user_name=$(grep -P 'user = ' -A 1 nix/secrets.nix | grep -oP '(?<=name = ")\w+(?=")')

# nixos-rebuild build --flake .#laptop2
nixos-generate --flake .#laptop2-installer --format iso --out-link result
# home-manager build --flake .#"$user_name"

ISO=$(find result/iso/ -iname '*.iso')
test -f "$ISO"
test -b /dev/sda

sudo umount /dev/sda* || true
sudo dd if="$ISO" of=/dev/sda status=progress
sync
sudo umount /dev/sda*
sudo rm /dev/sda*
