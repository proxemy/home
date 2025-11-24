{ secrets, pkgs, ... }:
{
  users.users.${secrets.user_name}.packages = [
    pkgs.keepassxc
  ];

  security.apparmor.policies.keepassxc = {
    state = "complain";
    profile = ''
      abi <abi/4.0>
      ${pkgs.keepassxc}/bin/keepassxc {}
    '';
  };
}
