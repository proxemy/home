{ secrets, ... }:
{
  home-manager.users.${secrets.username} = {
    programs.thunderbird.enable = true;
  };
}
