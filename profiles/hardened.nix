{
  modulesPath,
  secrets,
  ...
}:
{
  imports = [
    #"${modulesPath}/profiles/hardened.nix"
  ];

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

  # TMP: workaround for logrotate, a common dependency, failing to build
  # https://discourse.nixos.org/t/logrotate-config-fails-due-to-missing-group-30000
  #boot.kernel.sysctl."kernel.unprivileged_userns_clone" = 1;
}
