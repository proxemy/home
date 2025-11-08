{ secrets, ... }:
{
  services = {
    xserver.desktopManager.xfce.enable = true;
    displayManager.defaultSession = "xfce";
  };

  home-manager.users.${secrets.user_name} = {
    xfconf = {
      enable = true;
      settings = {
        xfce4-desktop = {
          # Disable all but workplace0
          "backdrop/screen0/monitorsLVDS-1/workplace0/color-style" = 0;
          "backdrop/screen0/monitorsLVDS-1/workplace0/image-style" = 0;
          "backdrop/screen0/monitorsLVDS-1/workplace0/last-image" = "";
        };
        xfce4-keyboard-shortcuts = {
          "commands/custom/override" = true;
          "commands/custom/<Primary><Alt>Delete" = "xfce4-session-logout";
          "commands/custom/<Primary><Alt>t" = "exo-open --launch TerminalEmulator";
          "commands/custom/<Primary><Shift>Escape" = "xfce4-taskmanager";
          "commands/custom/Print" = "xfce4-screenshooter";
          "commands/custom/<Super>f" = "thunar";
          "commands/custom/<Super>l" = "xflock4";
          "commands/custom/<Super>r" = "xfce4-appfinder -c";
          #"commands/custom/<Super>r/startup-notify" = true;

          "xfwm4/custom/override" = true;
          "xfwm4/custom/<Super>Up" = "maximize_window_key";
          "xfwm4/custom/<Super>Down" = "hide_window_key";
          "xfwm4/custom/<Super>Left" = "move_window_left_key";
          "xfwm4/custom/<Super>Right" = "move_window_right_key";
          "xfwm4/custom/<Super><Shift>End" = "move_window_next_workspace_key";
          "xfwm4/custom/<Super><Shift>Home" = "move_window_prev_workspace_key";
        };
        xfce4-panel = {
          "panels/dark-mode" = true;
        };
        xsettings = {
          "Net/ThemeName" = "Adwaita-dark";
        };
      };
    };
  };
}
