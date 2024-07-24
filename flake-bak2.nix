{
  description = "Test flake to build minimum raspeberry image.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
	nixos-hardware.url = "github:nixos/nixos-hardware?ref=kernel-latest";
	#nixos-generators.url = "";
  };

  outputs = { self, nixpkgs, nixos-hardware }:
  {
    packages.x86_64-linux.default = (nixpkgs.lib.nixosSystem {
      system = "armv7l-linux";
	  modules = [
        nixos-hardware.nixosModules.raspberry-pi-2
        "${nixpkgs}/nixos/modules/profiles/minimal.nix"
        #"${nixpkgs}/nixos/modules/installer/sd-card/sd-iamge-aarch64.nix"
		#"${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-new-kernel.nix"
		#"${nixpkgs}/nixos/modules/installer/sd-card/sd-image-raspberrypi.nix"
		#"${nixpkgs}/nixos/modules/installer/sd-card/sd-image-armv7l-multiplatform.nix"
		"${nixpkgs}/nixos/modules/installer/sd-card/sd-image-armv7l-multiplatform-installer.nix"
	  ];
	}).config.system.build.sdImage;
  };
}
