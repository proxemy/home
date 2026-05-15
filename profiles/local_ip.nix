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
    enableStrictShellChecks = true;
    serviceConfig.Type = "oneshot";
    script = with pkgs; ''
      ${iproute2}/bin/ip -brief -4 addr | ${gnugrep}/bin/grep --quiet "${host.ip}"
    '';
  };
}
