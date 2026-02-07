{ ... }:
{
  services.mpd = {
    enable = true;
    startWhenNeeded = true;
    #user = "mpd";

    openFirewall = false;
    settings.bind_to_address = "any";

    /*
      extraConfig = ''
        audio_output {
          type "pulse"
          name "PA MPD"
        }
      '';
    */
  };
}
