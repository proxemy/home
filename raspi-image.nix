{ pkgs, modulesPath, lib, ... }: {

  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  services.sshd.enable = true;
  users.users.root.password = "nixos"; # secrets.raspi.ssh.password;

  services.openssh.permitRootLogin = lib.mkDefault "yes";
  services.getty.autologinUser = lib.mkDefault "root";

  # use the latest Linux kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Needed for https://github.com/NixOS/nixpkgs/issues/58959
  boot.supportedFilesystems = lib.mkForce [ "btrfs" ];
}
