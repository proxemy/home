{
  pkgs,
  config,
  secrets,
  ...
}:
{
  home-manager.users.${secrets.user_name}.home.packages = [
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
