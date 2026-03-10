{ ... }:
{
  services.tor = {
    enable = true;
    openFirewall = true;
    client.enable = true;

    relay = {
      enable = true;
      role = "bridge";
    };

    # https://2019.www.torproject.org/docs/tor-manual.html.en
    # https://github.com/torproject/manual
    # https://tb-manual.torproject.org/
    # http://dsbqrprgkqqifztta6h3w7i2htjhnq7d3qkh3c7gvc35e66rrcv66did.onion/
    settings = rec {
      BandWidthRate = "1 MBytes";
      RelayBandwidthRate = BandWidthRate;
      #ConnLimit = 200;
      #ExtraInfo = "1";
      ConnDirectionStatistics = true;
    };
  };

  environment.shellAliases = {
    tor-status = ''
      systemctl status tor.service --no-pager
      #cat /var/lib/tor/fingerprint
      #cat /var/lib/tor/stats/*
    '';

  };
}
