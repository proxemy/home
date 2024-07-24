{
  description = "Test flake to build minimum raspeberry image."

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
	nixos-hardware.url = "github:nixos/nixos-hardware?ref=latest-kernel";
  };

  outputs = { nixpkgs, nixos-hardware }:
  {};
}
