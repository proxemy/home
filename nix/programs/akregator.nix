{
  pkgs,
  config,
  secrets,
  ...
}:
{
  home-manager.users.${secrets.username} =
    if config.hardware.graphics.enable then
      {
        home = {
          packages = [
            pkgs.kdePackages.akregator
          ];

          file.akregator_feeds = {
            target = ".local/share/akregator/data/feeds.opml";
            text = secrets.feeds.OPML;
            force = true;
          };
        };
      }
    else
      { };
}
