{
  modulesPath,
  ...
}:
{
  imports = [
    "${modulesPath}/profiles/hardened.nix"
  ];

  security = {
    #auditd.enable = true;
    apparmor.enable = true;
  };

  # TMP: workaround for logrotate, a common dependency, failing to build
  # https://discourse.nixos.org/t/logrotate-config-fails-due-to-missing-group-30000
  boot.kernel.sysctl = {
    "kernel.unprivileged_userns_clone" = 1;
  };
}
