# This function return an attribte set to generate hardened systemd service.
# TODO
{
  description,

  # parameters passed to ServiceConfig
  PrivateTmp ? "yes",
  NoNewPrivileges ? true,
  ProtectSystem ? "strict",
  CapabilityBoundingSet ? "CAP_NET_BIND_SERVICE CAP_DAC_READ_SEARCH",
  RestrictNamespaces ? "uts ipc pid user cgroup net mnt",
  ProtectKernelTunables ? "yes",
  ProtectKernelModules ? "yes",
  ProtectControlGroups ? "yes",
  PrivateDevices ? "yes",
  RestrictSUIDSGID ? true,
  IPAddressAllow,
}:
{
  inherit description;

  # see: https://github.com/alegrey91/systemd-service-hardening
  serviceConfig = {
    inherit
      PrivateTmp
      NoNewPrivileges
      ProtectSystem
      CapabilityBoundingSet
      RestrictNamespaces
      ProtectKernelTunables
      ProtectKernelModules
      ProtectControlGroups
      PrivateDevices
      RestrictSUIDSGID
      IPAddressAllow
      ;
  };
}
