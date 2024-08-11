{ pkgs, ... }:
{
	# https://www.tweag.io/blog/2020-07-31-nixos-flakes/
	# "required to have nix beta flake support"
	#nix.package = pkgs.nixUnstable; # nixUnstable ist deprecated, use nixVersions.{latest,git}
	nix.package = pkgs.nixVersions.latest;

	nix.settings.system-features = [ "nix-command" "flakes" "big-parallel" "kvm" ];
	nix.extraOptions = "experimental-features = nix-command flakes";

	environment.systemPackages = with pkgs; [
		git
		tmux
		neovim
	];

	# not supported by flakes. will copy /etc/nixos/configuration.nix into iso
	system = {
		stateVersion = "24.11";
		autoUpgrade = {
			enable = true;
			allowReboot = true;
			dates = "04:00";
			flake = "github:proxemy/home";
			flags = [ "-L" "--show-trace" "--verbose" "--no-eval-cache" ];
			randomizedDelaySec = "30min";
		};
	};

	hardware.bluetooth.enable = false;
}
