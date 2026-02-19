{
  lib,
  host,
  secrets,
  ...
}:
let
  local_hostkey = "/etc/ssh/hostkey";
in
{
  services.openssh = {
    enable = true;

    settings = {
      AllowUsers = [ secrets.username ];
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      UseDns = false;
      X11Forwarding = false;
    };

    generateHostKeys = false;
    hostKeys = lib.mkForce [
      {
        inherit (host.hostkey.private) type;
        path = local_hostkey;
      }
    ];

    extraConfig = ''
      Banner none
      LoginGraceTime 10
      AllowAgentForwarding no
      AllowTcpForwarding no
      PermitTunnel no
      PermitUserEnvironment no
    '';

    knownHosts = secrets.ssh_known_hosts;
  };

  system.activationScripts.init_hostkey = {
    deps = [ "etc" ];
    supportsDryActivation = true;
    text = ''
      cp ${host.hostkey.private.path} ${local_hostkey}
      chmod a=-rwx,u+r ${local_hostkey}
    '';
  };
}
