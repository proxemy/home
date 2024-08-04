{ config, lib, pkgs, ... }:
{
	nix.settings.system-features = [ "nix-command" "flakes" "big-parallel" "kvm" ];
	nix.extraOptions = "experimental-features = nix-command flakes";

	boot= {
		supportedFilesystems = [ "ext4" ];
		loader.grub.device = "/dev/sda";
	};

	environment.systemPackages = with pkgs; [
		git
		tmux
		neovim
	];

	# not supported by flakes. will copy /etc/nixos/configuration.nix into iso
	#system.copySystemConfiguration = true;

	installer.cloneConfigIncludes = [ "./common.nix" ];

	isoImage = {
		edition = lib.mkForce "laptop2";
		isoBaseName = "laptop2-nixos";
		volumeID = "laptop2-nixos";
		contents = [
			# TODO move this to hostname parameterizable or specialized install.nix
			{ source = pkgs.writeText "install.sh" ''
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
sudo nixos-install
#sudo nixos-install --flake "github:proxemy/home#laptop2"
'';
			  target = "/install.sh";
			}
			#{ 
			  #source = ../flake.nix;
			  #source = "${sourceInfo.outpath}" + "/*";
			  #source = self.sourceInfo.outPath + "/*";
			  #target = "/";
			#}
		];
	};
}
