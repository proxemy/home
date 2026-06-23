{ pkgs, secrets, ... }:
{
  home-manager.users.${secrets.username} = {

    home.packages = [
      pkgs.redshift
    ];

    xdg.configFile."redshift.conf".text = ''
      [redshift]
      temp-day=5700
      temp-night=2400
      gamma-day=0.8
      gamma-night=0.4
      adjustment-method=randr
      location-provider=manual

      [manual]
      lat=${secrets.location.lat}
      lon=${secrets.location.lon}
    '';
  };
}
