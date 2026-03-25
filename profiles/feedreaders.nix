{ self, ... }:
{
  imports = [
    "${self}/programs/newsboat.nix"
    "${self}/programs/akregator.nix"
  ];
}
