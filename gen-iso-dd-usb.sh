#!/usr/bin/env bash

set -xeuo pipefail

nixos-generate --show-trace --flake .#laptop2 --format iso --out-link result
ISO="result/iso/laptop2-nixos-24.11.20240725.5ad6a14-x86_64-linux.iso"
test -f "$ISO"
test -b /dev/sda

sudo umount /dev/sda* || true
sudo dd if="$ISO" of=/dev/sda status=progress
sync
sudo umount /dev/sda*
sudo rm /dev/sda*
