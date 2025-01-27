# This function return an attribte set to generate hardened systemd service.
# TODO
{
  description,
}:
{
  inherit description;

  # see: https://github.com/alegrey91/systemd-service-hardening
  serviceConfig = {
    PrivateTmp = "yes";
    NoNewPrivileges = true;
    ProtectSystem = "strict";
    CapabilityBoundingSet = "CAP_NET_BIND_SERVICE CAP_DAC_READ_SEARCH";
    RestrictNamespaces = "uts ipc pid user cgroup";
    ProtectKernelTunables = "yes";
    ProtectKernelModules = "yes";
    ProtectControlGroups = "yes";
    PrivateDevices = "yes";
    RestrictSUIDSGID = true;
    #IPAddressAllow = "192.168.1.0/24";
  };
}
