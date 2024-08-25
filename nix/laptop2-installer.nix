{ pkgs, lib, secrets, sourceInfo, /*laptop2, dotfiles*/ ... }:
{
	#installer.cloneConfigIncludes = [ "./common.nix" ];
	#nix.nixPath = [ "nixos-config=github:proxemy/home" ];
	#system = {
		#copySystemConfiguration = true;
		#nixos-generate-config.configuration = "asd wert";
	#};

	isoImage = {
		edition = lib.mkForce "laptop2";
		isoBaseName = "laptop2-nixos";
		volumeID = "laptop2-nixos";

		# TODO: finalize a self contained/offline installer iso
		# the 2 options might be a lead. 'includeSystemBuildDeps' bloats the
		# nix/store extremly and storeContents expects JSON as input.
		#includeSystemBuildDependencies = true;
		#storeContents = [ laptop2 ];

		contents = [
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

sudo mkdir /mnt/etc/nixos/home
sudo cp -r /iso/flake-sourceInfo/* /mnt/etc/nixos/home/
CWD=/mnt/etc/nixos/home sudo git-crypt unlock /iso/git-crypt-key-file
sudo nixos-install --flake /mnt/etc/nixos/home#laptop2 --root /mnt --verbose
'';
			  target = "/install.sh";
			}
			{ source = sourceInfo.outPath;
			  target = "/flake-sourceInfo";
			}
			{ source = secrets.git-crypt.key-file;
			  target = "/git-crypt-key-file";
			}
		];
	};
}
