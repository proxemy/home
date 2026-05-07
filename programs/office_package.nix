{ pkgs, secrets, ... }:
{
  home-manager.users.${secrets.username}.home.packages = with pkgs; [
    libreoffice
    galculator

    # PDF viewer
    atril
  ];

  environment.systemPackages = with pkgs; [
    hunspell
    hunspellDicts.en_US
    hyphenDicts.en_US
    hunspellDicts.${secrets.locale}
    hyphenDicts.${secrets.locale}
  ];
}
