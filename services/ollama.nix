{ pkgs, lib, ... }:
let
  user = "ollama";
in
rec {
  users.users.${user} = {
    home = "/home/${user}";
    createHome = true;
    homeMode = "755";
    #shell = "${lib.getBin pkgs.util-linux}/bin/nologin";
  };

  services.ollama = {
    enable = true;
    inherit user;
    group = user;
    package = pkgs.ollama-rocm;
    home = users.users.${user}.home;
  };

  systemd.services.ollama = {
    enable = lib.mkForce false;
    #  confinement = {
    #    enable = true;
    #    packages = [ pkgs.ollama-rocm ];
    #  };
    #  environment.UMask = "0022";
  };
}
