{ pkgs, secrets, ... }:
{
  home-manager.users.${secrets.username}.home.packages = with pkgs; [
    libreoffice
    hunspell
    hunspellDicts.en_US
    hyphenDicts.en_US
    hunspellDicts.${secrets.locale}
    hyphenDicts.${secrets.locale}

    # PDF viewer
    mate.atril
  ];
}
