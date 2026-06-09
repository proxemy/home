{ secrets, ... }:
{
  home-manager.users.${secrets.username} = {
    programs.thunderbird = {
      enable = true;

      profiles.default = {
        isDefault = true;

        settings = {
          "mail.spellcheck.inline" = false;
          "extensions.activeThemeID" = "thunderbird-compact-dark@mozilla.org";

          "javascript.enabled" = false;
          "network.protocol-handler.warn-external.http" = true;
          "network.protocol-handler.warn-external.https" = true;

          "mailnews.display.prefer_plaintext" = true;
          "plain_text.wrap_long_lines" = false;

          "network.proxy.socks" = secrets.tor_proxy.ip;
          "network.proxy.socks_port" = secrets.tor_proxy.socks_port;
          "network.proxy.allow_bypass" = false;
        };
      };
    };
  };
}
