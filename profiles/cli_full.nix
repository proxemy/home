{
  pkgs,
  self,
  secrets,
  ...
}:
{
  imports = [
    ./cli_minimal.nix
    "${self}/programs/neovim/"
  ];

  programs = {
    wireshark.enable = true;
    usbtop.enable = true;
    htop.enable = true;
    sedutil.enable = true;
  };

  users.users.${secrets.username}.packages = with pkgs; [
    bc
    dig
    exiftool
    gnupg
    jq
    libxml2
    python3
    ripgrep
    unzip
    usbutils
  ];

  environment.systemPackages = with pkgs; [
    #man-pages
    #man-pages-posix
  ];
}
