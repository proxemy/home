{ secrets, self, ... }:
{
  home-manager.users.${secrets.username} = {
    programs.thunderbird = {
      enable = true;

      profiles.default = {
        isDefault = true;

        settings =
          let
            socks_ip = secrets.hosts.rpi2.ip;
            socks_port =
              self.nixosConfigurations.${secrets.hotnames.rpi2}.config.services.tor.client.socksListenAddress.port;
          in
          {
            "mail.spellcheck.inline" = false;
            "extensions.activeThemeID" = "thunderbird-compact-dark@mozilla.org";

            "javascript.enabled" = false;
            "network.protocol-handler.warn-external.http" = true;
            "network.protocol-handler.warn-external.https" = true;

            "mailnews.display.prefer_plaintext" = true;
            "plain_text.wrap_long_lines" = false;

            "network.proxy.socks" = socks_ip;
            "network.proxy.socks_port" = socks_port;
            "network.proxy.allow_bypass" = false;
          };
      };
    };
  };
}
