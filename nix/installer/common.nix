{ pkgs, ... }:
{
	environment.systemPackages = with pkgs; [
		git git-crypt
	];

	nix = {
		package = pkgs.nixVersions.latest;
		settings.system-features = [ "nix-command" "flakes" "big-parallel" "kvm" ];
	};

	#isoImage.storeContents = [ sourceInfo ];
}
