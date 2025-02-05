{ ... }:
{
  services.mpd = {
    enable = true;

    network = {
      listenAddress = "any";
      statWhenNeeded = true;
    };

    extraConfig = ''
      audio_output {
        type "pulse"
        name "PA MPD"
      }
    '';
  };
}
