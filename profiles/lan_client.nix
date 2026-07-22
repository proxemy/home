{ pkgs, host, ... }:
{
  networking.useNetworkd = true; # experimental feature in stateVersion 26.05!

  systemd.network.networks."10-dhcp" = {
    matchConfig.Name = "en* eth* wlan*";

    networkConfig.DHCP = "ipv4";

    dhcpV4Config.RequestAddress = host.ip;
  };

  systemd.services.lan-check = {
    description = "Check requested LAN-IPv4";
    after = [ "network-online.target" ];
    requiredBy = [ "multi-user.target" ];
    enableStrictShellChecks = true;
    serviceConfig.Type = "oneshot";

    path = with pkgs; [
      iproute2
      gnugrep
      #coreutils-full
      findutils
    ];

    # TODO: status check of tor relay and systemd logging
    script = ''
      ret=0

      ip=$(ip -brief -oneline -4 addr show to "${host.ip}" | xargs)

      if [[ ! "$ip" =~ ${host.ip} ]]; then
        echo "Expected ${host.ip} but found: $ip"
        ret=$((ret | 1))
      else
        echo "$ip"
      fi

      exit $ret
    '';
  };
}
