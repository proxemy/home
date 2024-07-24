with import <nixpkgs> {
  crossSystem = {
    config = "aarch64-unknown-linux-gnu";
  };
};

mkShell {
  #buildInputs = [ hello nixos-generators ]; # your dependencies here
  packages = [ nixos-generators ];
}
