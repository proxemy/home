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
      AllowedUsers = secrets.username;
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
      ChallengeResponseAuthentication no
      KerberosAuthentication no
      GSSAPIAuthentication no
      AllowAgentForwarding no
      AllowTcpForwarding no
      PermitTunnel no
      PermitUserEnvironment no

      # TODO migrate to/create ssh client config
      #UseRoaming no # <- client config
    '';

    knownHosts = secrets.ssh_known_hosts;
  };
}
