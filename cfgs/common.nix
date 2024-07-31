{ config, lib, pkgs, ... }:
{
	# this seems to be an unknown property and breaks the iso with unpopulated /mnt-root in stage 1
	#nix.settings.system-features = [ "nix-command" "flakes" "big-parallel" "kvm" ];

	boot.supportedFilesystems = [ "ext4" ];
	#boot.supportedFilesystems.zfs = lib.mkForce false; # some day, *-no-zfs.nix installer might be obsolete

	environment.systemPackages = with pkgs; [
		git
		tmux
		neovim
	];
	
	# TODO move this to specialized laptop2.nix
	isoImage = {
		isoBaseName = "laptop2-nixos";
		volumeID = "laptop2-nixos";
		contents = [
			{ source = (pkgs.writeTextDir "test.sh" "echo TEST") + "/test.sh";
			  target = "test.sh";
			}
		];
	};
}
