{
  config,
  pkgs,
  lib,
  secrets,
  ...
}:
let
  gtk_theme = "Adwaita-dark";
in
{
  services = {
    xserver = {
      desktopManager.xfce.enable = true;
      displayManager.lightdm = {
        enable = true;
        greeters.gtk = {
          enable = true;
          # greeter color theme. before login, user config is not loaded
          theme.name = gtk_theme;
        };
      };
    };
    displayManager.defaultSession = "xfce";
  };

  # TODO: maybe move this to a dedicated profile/sound.nix
  #users.users.${secrets.username}.packages = with pkgs; [
  programs.thunar.plugins = with pkgs; [
    thunar-volman
    xfce4-pulseaudio-plugin
  ];

  home-manager.users.${secrets.username} = {
    gtk.colorScheme = "dark";

    #
    # XFCE config files are stored in ~/.config/xfce4/xfconf
    # xfconf-query -c CHANNEL (-l) -p PROPERTY
    # xfconf-query -c xfce4-desktop -p "/last/window-height"
    #

    xfconf = {
      enable = true;
      settings = {
        xfce4-desktop = { };

        xfce4-keyboard-shortcuts = {
          #"providers" = [ "xfwm4" "commands" ];

          # commands handles launching hotkeys
          "commands/custom/override" = true;
          "commands/custom/<Primary><Alt>Delete" = "xfce4-session-logout";
          "commands/custom/<Super>t" = "exo-open --launch TerminalEmulator";
          "commands/custom/<Super>b" = "exo-open --launch WebBrowser";
          "commands/custom/<Super>f" = "exo-open --launch FileManager";
          "commands/custom/<Super>m" = "exo-open --launch MailReader";
          "commands/custom/<Super>Escape" = "xfce4-taskmanager";
          "commands/custom/Print" = "xfce4-screenshooter";
          "commands/custom/<Super>l" = "xflock4";
          "commands/custom/<Super>r" = "xfce4-appfinder";

          # xfwm4 handles window manager hotkeys
          "xfwm4/custom/override" = true;
          "xfwm4/custom/<Alt>Tab" = "cycle_windows_key";
          "xfwm4/custom/<Alt><Shift>Tab" = "cycle_reverse_windows_key";

          "xfwm4/custom/<Super>Up" = "maximize_window_key";
          "xfwm4/custom/<Super>Down" = "hide_window_key";
          "xfwm4/custom/<Super>Left" = "tile_left_key";
          "xfwm4/custom/<Super>Right" = "tile_right_key";
          "xfwm4/custom/<Super><Shift>Left" = "move_window_to_monitor_left_key";
          "xfwm4/custom/<Super><Shift>Right" = "move_window_to_monitor_right_key";

          "xfwm4/custom/<Super>d" = "show_desktop_key";
          "xfwm4/custom/<Alt>F4" = "close_window_key";
          "xfwm4/custom/Escape" = "cancel_key";
          "xfwm4/custom/F11" = "fullscreen_key";
        };

        xfce4-panel = {
          "panels/dark-mode" = true;

          # Experimental xpath config
          #"//*[@name='digital-date-format']" = "%Y-%m-%d";
          #"//*[@name='digital-time-format']" = "%a, %R";
          "plugins/plugin-8/digital-date-format" = "%Y_%m_%d";
          "plugins/plugin-8/digital-time-format" = "%a, %R";
          # TODO: fixed indexes (panel-8) are bad, might break in the future.
          #"panels/*/digital-time-format" = "%a, %R";
        };

        xsettings = {
          "Net/ThemeName" = gtk_theme;
        };

        xfwm4 = {
          # window decorations theme
          "general/theme" = "Tgc";

          # Disable compositor as a workaround for latest nvidia driver flickering
          "general/use_compositing" = if config.hardware.nvidia.enabled then false else true;

          "general/workspace_count" = 1;
          "general/scroll_workspaces" = false;
          "general/prevent_focus_stealing" = false;
          "general/urgent_blink" = true;
          "general/repeat_urgent_blink" = true;
        };
      };
    };

    xdg = {
      mimeApps.associations.added."text/plain" = "writer.desktop;org.xfce.mousepad.desktop";
      configFile."mimeapps.list".force = true;
    };
  };
}
