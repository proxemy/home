{
  lib,
  host,
  secrets,
  ...
}:
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
    hostKeys = lib.mkForce [ host.hostkey.private ];

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
}
