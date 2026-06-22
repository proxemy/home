{ pkgs, secrets, ... }:
{
  home-manager.users.${secrets.username} = {

    home.packages = [ pkgs.vlc ];

    xdg.mimeApps = {
      defaultApplications."inode/directory" = "vlc.desktop";
      associations.added."inode/directory" = "vlc.desktop";
    };
  };
}
