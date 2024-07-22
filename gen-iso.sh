#!/usr/bin/sh

nix-shell -p nixos-generators --run "nixos-generate --format iso --configuration ./raspi-image.nix -o result"

# dd if=result/iso/*.iso of=/dev/sdTODO status=progress
# sync

