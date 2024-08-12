{ pkgs, ... }:
{
	# https://www.tweag.io/blog/2020-07-31-nixos-flakes/
	# "required to have nix beta flake support"
	nix.package = pkgs.nixVersions.latest;

	nix.settings.system-features = [ "nix-command" "flakes" "big-parallel" "kvm" ];
	nix.extraOptions = "experimental-features = nix-command flakes";

	# TODO: move these packages in a user context, not global installation.
	environment.systemPackages = with pkgs; [
		git
		tmux
		neovim
		mtr
	];

	system = {
		stateVersion = "24.11";
		autoUpgrade = {
			enable = true;
			allowReboot = true;
			dates = "04:00";
			flake = "github:proxemy/home";
			flags = [ "-L" ]; # to get extended build logs
			randomizedDelaySec = "30min";
		};
	};

	hardware.bluetooth.enable = false;
}
