{
  pkgs,
  lib,
  modulesPath,
  cfg,
  secrets,
  ...
}:
{
  security = {
    #auditd.enable = true;
    apparmor.enable = true;
  };

  networking.firewall = {
    logRefusedConnections = true;
    logRefusedPackets = true;
    logReversePathDrops = true;
  };

  nix.settings.allowed-users = [ secrets.username ];

  # breaks alot of desktop apps
  environment.memoryAllocator.provider = lib.mkDefault "graphene-hardened";

  # TODO: load kernel modules required by iptables that are disallowed by 'modules_disabled'
  boot.kernel.sysctl = {
    #"kernel.modules_disabled" = 1;
    #"kernel.unprivileged_userns_clone" = 0;

    "kernel.printk" = if cfg.debug then 6 else 4;
  };

  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  system.etc.overlay.mutable = false;
}
