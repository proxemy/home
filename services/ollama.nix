{ pkgs, lib, ... }:
let
  user = "ollama";
  pkg = pkgs.ollama-rocm;
in

{
  services.ollama = {
    enable = true;
    inherit user;
    group = user;
    package = pkg;
  };

  systemd.services.ollama = {
    enable = true;
    confinement.enable = true;
    wantedBy = lib.mkForce [ ];
  };
}
