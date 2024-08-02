{ config, lib, pkgs, ... }:
{
	# this seems to be an unknown property and breaks the iso with unpopulated /mnt-root in stage 1
	nix.settings.system-features = [ "nix-command" "flakes" "big-parallel" "kvm" ];
	nix.extraOptions = "experimental-features = nix-command flakes";

	boot.supportedFilesystems = [ "ext4" ];

	environment.systemPackages = with pkgs; [
		git
		tmux
		neovim
	];

	
	# TODO move this to specialized laptop2.nix
	isoImage = {
		edition = lib.mkForce "laptop2";
		isoBaseName = "laptop2-nixos";
		volumeID = "laptop2-nixos";
		contents = [
			{ source = pkgs.writeText "partition.sh" ''
#!/usr/bin/bash
set -xeuo pipefail

DEV="$1"

sudo partx --show "$DEV"

echo "Partitioning disc: '$DEV'! All data will be lost!"
read -p "Proceed? [y/N]:" confirm
[[ "$confirm" =~ y|Y ]] || { echo "Arborting"; exit 0; }

sudo wipefs "$DEV"
sudo parted -s "$DEV" mklabel msdos

sudo parted -s "$DEV" -- mkpart primary 1MB -16GB
sudo parted -s "$DEV" -- set 1 boot on
sudo parted -s "$DEV" -- mkpart primary linux-swap -16GB 100%

sudo mkfs.ext4 -L nixos "$DEV"1
sudo mkswap -L swap "$DEV"2

sudo mount /dev/disk/by-label/nixos /mnt
sudo swapon /dev/disk/by-label/swap

sudo nixos-generate-config --root /mnt
echo "RUN: sudo nixos-install"
'';
			  target = "partition.sh";
			}
		];
	};
}
