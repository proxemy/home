{ ... }:
{
  services.mpd = {
    enable = true;
    startWhenNeeded = true;
    #user = "mpd";

    network = {
      listenAddress = "any";
    };

    /*extraConfig = ''
      audio_output {
        type "pulse"
        name "PA MPD"
      }
    '';*/
  };
}
