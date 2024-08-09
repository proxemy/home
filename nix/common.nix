{ pkgs, ... }:
{
	# https://www.tweag.io/blog/2020-07-31-nixos-flakes/
	# "required to have nix beta flake support"
	nix.package = pkgs.nixUnstable;

	nix.settings.system-features = [ "nix-command" "flakes" "big-parallel" "kvm" ];
	nix.extraOptions = "experimental-features = nix-command flakes";
	#nix.nixPath = [ "nixos-config=github:proxemy/home" ];

	environment.systemPackages = with pkgs; [
		git
		tmux
		neovim
	];

	# not supported by flakes. will copy /etc/nixos/configuration.nix into iso
	#system.copySystemConfiguration = true;
	system = {
		stateVersion = "24.11";
		autoUpgrade = {
			enable = true;
			allowReboot = true;
			dates = "04:00";
		};
		#nixos-generate-config.configuration = "asd wert";
	};

	hardware.bluetooth.enable = false;
}
