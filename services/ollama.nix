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

    loadModels = [
      "gemma3:27b"
      "deepseek-v3"
      "codellama:70b"
    ];
  };

  systemd.services.ollama = {
    enable = true;
    confinement.enable = true;
    wantedBy = lib.mkForce [ ];
  };
}
