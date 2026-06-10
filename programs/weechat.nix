{ pkgs, secrets, ... }:
{
  #services.weechat = {
  #  enable = true;
  #  headless = true;
  #};

  home-manager.users.${secrets.username} = {
    home.packages = [ pkgs.weechat ];

    home.shellAliases = {
      weechat = "${pkgs.weechat}/bin/weechat --no-plugin --no-script --temp-dir";
    };
  };

}
