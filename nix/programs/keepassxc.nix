{ secrets, pkgs, ... }:
{
  users.users.${secrets.user_name}.packages = [
    pkgs.keepassxc
  ];
}
