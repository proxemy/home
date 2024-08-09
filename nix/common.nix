{ pkgs, ... }:
{
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
