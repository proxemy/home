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

          file.akregator_feeds =
            let
              source = builtins.toFile "feeds.opml" secrets.feeds.OPML;
              target_dir = ".local/share/akregator/data/feeds.opml";
            in
            {
              inherit source;
              onChange = ''
                chmod 0077
                cp ${source} ~/${target_dir}
              '';
            };
        };
      }
    else
      { };
}
