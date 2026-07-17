{ pkgs, host, ... }:
{
  networking.useNetworkd = true; # experimental feature in stateVersion 26.05!

  systemd.network.networks."10-dhcp" = {
    matchConfig.Name = "en* eth* wlan*";

    networkConfig = {
      DHCP = "ipv4";
    };

    dhcpV4Config = {
      RequestAddress = host.ip;
    };
  };

  systemd.services.local-ip-check = {
    description = "Check requested LAN-IPv4";
    after = [ "network.target" ];
    requiredBy = [ "multi-user.target" ];
    enableStrictShellChecks = true;
    serviceConfig.Type = "oneshot";
    path = with pkgs; [
      iproute2
      gnugrep
      #coreutils-full
      findutils
    ];
    script = ''
      out=$(ip -brief -oneline -4 addr show to "${host.ip}" | xargs)
      echo "$out"
      [[ "$out" =~ ${host.ip} ]]
    '';
  };
}
