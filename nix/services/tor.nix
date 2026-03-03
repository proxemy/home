{ ... }:
{
  services.tor = {
    enable = true;

    relay.role = [
      "bridge"
      "relay"
    ];
  };
}
