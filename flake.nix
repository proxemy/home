{
  description = "Test flake to build minimum raspeberry image.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
	#nixos-hardware.url = "github:nixos/nixos-hardware?ref=kernel-latest";
  };

  outputs = inputs@{ self, nixpkgs, ... }: {
    nixosConfigurations = {
		laptop2 = nixpkgs.lib.nixosSystem {
			system = "x86_64-linux";
			modules = [
				"${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix"
				# TODO reactivate hardened kernel and find missing ext4 support in installer
				#"${nixpkgs}/nixos/modules/profiles/hardened.nix"
				./nix/common.nix
			];
		};
		f = nixpkgs.lib.mkFlake {};
	};
  };
}
