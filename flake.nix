{
  description = "Test flake to build minimum raspeberry image.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
	nixos-hardware.url = "github:nixos/nixos-hardware?ref=kernel-latest";
	#nixos-generators.url = "";
  };

  outputs = { self, nixpkgs, nixos-hardware }:
  {
    laptop2 = "todo";

    packages.x86_64-linux.default = (nixpkgs.lib.nixosSystem {
	  modules = [];
	});
  };
}
