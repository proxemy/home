{
  ...
}@args:
{
  # see: https://github.com/alegrey91/systemd-service-hardening

  #CapabilityBoundingSet ? "CAP_NET_BIND_SERVICE CAP_DAC_READ_SEARCH",
  IPAddressAllow = "localhost";
  IPAddressDeny = "any";
  LockPersonality = true;
  MemoryDenyWriteExecute = true;
  NoNewPrivileges = true;
  PrivateBPF = true;
  PrivateDevices = true;
  PrivateIPC = true;
  PrivateTmp = true;
  PrivateUsers = true;
  ProtectControlGroups = true;
  ProtectHome = true; # "read-only"
  ProtectHostname = true;
  ProtectKernelLogs = true;
  ProtectKernelModules = true;
  ProtectKernelTunables = true;
  ProtectProc = "invisible";
  ProtectSystem = "strict";
  RestrictNamespaces = true; # "uts ipc pid user cgroup net mnt",
  RestrictRealtime = true;
  RestrictSUIDSGID = true;
}
// args
