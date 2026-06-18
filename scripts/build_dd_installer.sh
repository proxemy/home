#!/usr/bin/env bash

if [ $# -lt 1 ]; then
	echo -e \
		"USAGE: $(basename "$0")\n"\
		"- nix run .#dd-installer -- <host_name> [<target_device>]\n"\
		"-- <host_name>: A flake output with '-installer' suffix.\n"\
		"-- <target_device>: Block device to dd the ISO onto."
	exit 255
fi

set -euo pipefail

host_name="${1:-$ARG1_host_name}"
target_device="${2:-$ARG2_target_device}"

if [[ -z "$target_device" ]] || ! [[ -b "$target_device" ]]; then
	echo "Target block device '$target_device' not found."
	exit 1
fi

nixos-generate --flake .#"$host_name" --format iso --out-link result

iso=$(find result/iso/ -iname '*.iso')

if [ ! -f "$iso" ]; then
	echo "No result ISO file found!" >&2
	exit 2
fi

echo "Writing to '$target_device': " "$(du -h "$iso")"
set -x
sudo umount "$target_device"* || true
sudo dd if="$iso" of="$target_device" status=progress conv=fsync
