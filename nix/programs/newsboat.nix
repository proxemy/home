{ pkgs, secrets, ... }:
{
  home-manager.users.${secrets.username} = {
    home.packages = [
      pkgs.newsboat
    ];

    xdg.configFile."newsboat/urls" = {
      force = true;
      text = secrets.feeds.newsboat_url_list;
    };
  };
}
