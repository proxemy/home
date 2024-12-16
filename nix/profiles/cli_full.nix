{ pkgs, ... }:
{
  imports = [
    ./cli_minimal.nix

    ./../programs/neovim.nix
  ];

  # TODO: segregate stull into cli_minimal/full. Its all in one for now here
  programs = {
    wireshark.enable = true;
    mtr.enable = true;
    usbtop.enable = true;
    htop.enable = true;
    sedutil.enable = true;
  };

  environment = {
    systemPackages = with pkgs; [
      file
      exiftool
    ];
  };

}
