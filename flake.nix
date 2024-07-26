{
  description = "Test flake to build minimum raspeberry image.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
	#nixos-hardware.url = "github:nixos/nixos-hardware?ref=kernel-latest";
  };

  outputs = inputs@{ self, nixpkgs, ... }: {
    nixosConfigurations.laptop2 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        #./configuration.nix
      ];
    };
  };
}
