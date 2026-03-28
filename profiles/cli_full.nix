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

  # TODO: segregate stull into cli_minimal/full. Its all in one for now here
  programs = {
    wireshark.enable = true;
    usbtop.enable = true;
    htop.enable = true;
    sedutil.enable = true;
  };

  users.users.${secrets.username}.packages = with pkgs; [
    dig
    exiftool
    gnupg
    jq
    python3
    ripgrep
    usbutils
  ];

  environment.systemPackages = with pkgs; [
    #man-pages
    #man-pages-posix
  ];
}
