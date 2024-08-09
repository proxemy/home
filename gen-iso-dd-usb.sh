#!/usr/bin/env bash

set -xeuo pipefail

nixos-generate --flake .#laptop2-installer --format iso --out-link result
ISO=$(find result/iso/ -iname '*.iso')
test -f "$ISO"
test -b /dev/sda

sudo umount /dev/sda* || true
sudo dd if="$ISO" of=/dev/sda status=progress
sync
sudo umount /dev/sda*
sudo rm /dev/sda*
