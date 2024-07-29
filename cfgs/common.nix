{ config, lib, pkgs, ... }:
{
	# this seems to be an unknown property and breaks the iso with unpopulated /mnt-root in stage 1
	#nix.settings.experimental-features = [ "nix-command" "flakes" ];

	boot.supportedFilesystems = [ "ext4" ];
	#boot.supportedFilesystems.zfs = lib.mkForce false; # some day, *-no-zfs.nix installer might be obsolete

	environment.systemPackages = with pkgs; [
		git
		tmux
		neovim
	];
}
