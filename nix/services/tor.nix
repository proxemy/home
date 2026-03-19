{ sourceInfo, ... }:
{
  imports = [
    "${sourceInfo}/nix/secrets/tor.nix"
  ];

  services.tor = {
    enable = true;
    openFirewall = true;
    client.enable = true;

    relay = {
      enable = true;
      role = "relay";
    };

    # https://2019.www.torproject.org/docs/tor-manual.html.en
    # https://2019.www.torproject.org/docs/documentation
    # https://community.torproject.org/relay/
    # https://tb-manual.torproject.org/
    # https://github.com/torproject/manual
    # http://dsbqrprgkqqifztta6h3w7i2htjhnq7d3qkh3c7gvc35e66rrcv66did.onion/
    settings = rec {
      BandWidthRate = "1 MBytes";
      RelayBandwidthRate = BandWidthRate;

      ExitRelay = false;
      #Sandbox = true;

      ORPort = [ 9001 ]; # Onion Routing Port for data
      #DirPort = [ 9030 ]; # Directory Port for node organisation # not for bridge relays
      #ConnLimit = 200;

      HeartbeatPeriod = "2 hours"; # log message interval, default: 6 hours
      EntryStatistics = true;
      #ExtraInfoStatistics = true; # upload extra telemetry
      ConnDirectionStatistics = true;
      MainloopStats = true;
    };
  };

  environment.shellAliases = {
    tor-status = ''
      systemctl status tor.service --no-pager
      #cat /var/lib/tor/fingerprint
      #cat /var/lib/tor/stats
    '';
  };
}
