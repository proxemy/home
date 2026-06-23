{ lib, secrets, ... }:
let
  enable_webinterface = true;
in
{
  services.pihole-ftl = {
    enable = true;

    webserverEnabled = enable_webinterface;
    openFirewallWebserver = enable_webinterface;
    openFirewallDNS = true;

    # https://docs.pi-hole.net/ftldns/configfile/
    settings = {
      dns.upstreams = [
        "1.1.1.1"
        "9.9.9.9"

        # ffmuc.net, München
        "185.150.99.255"
        "5.1.66.255"

        # 8solutions.de, Hetzner
        "168.119.27.54"
        "168.119.61.220"

        # contabo.net
        "194.163.181.207" # Düsseldorf
        "161.97.85.60" # Nürnberg
      ];

      dns.hosts = lib.attrsets.mapAttrsToList (n: v: "${v.ip} ${n}") secrets.hosts;
    };

    lists = [
      {
        url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.txt";
        type = "block";
        enabled = true;
        description = "Hagezi";
      }
      {
        url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
        type = "block";
        enabled = true;
        description = "StevenBlack";
      }
    ];
  };

  services.pihole-web = {
    enable = enable_webinterface;
    ports = [ "443s" ];
  };
}
