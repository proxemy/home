{
  pkgs,
  config,
  secrets,
  ...
}:
{
  home-manager.users.${secrets.username}.home.packages = [
    pkgs.newsboat
  ]
  ++ (
    if config.hardware.graphics.enable then
      [
        pkgs.gnome-feeds
      ]
    else
      [ ]
  );
}
