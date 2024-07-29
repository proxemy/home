{ config, lib, pkgs, ... }:
{
	# this seems to be an unknown property and breaks the iso with unpopulated /mnt-root in stage 1
	#nix.settings.experimental-features = [ "nix-command" "flakes" ];

	boot.supportedFilesystems = [ "ext4" ];

	environment.systemPackages = with pkgs; [
		git
		tmux
		neovim
	];
}
