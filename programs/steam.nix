{ pkgs, ... }:
{
  # https://nixos.wiki/wiki/Steam
  programs.steam.enable = true;

  nixpkgs.config.allowUnfreePackages = [
    "steam"
    "steam-unwrapped"
  ];

  systemd =
    let
      name = "steam-guard";
    in
    {

      timers.${name} = {
        description = "${name}.timer triggers ${name}.service periodically.";

        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = 0;
          OnCalendar = "Mon..Fri *-*-* 00..18:*";
        };

        unitConfig = {
          CanStop = false;
          RefuseManualStop = true;
          StopWhenUnneeded = false;
        };
      };

      services.${name} = {
        description = "Kill steam and make it non-executable.";
        enableStrictShellChecks = true;
        after = [ "multi-user.target" ];

        serviceConfig = {
          Type = "oneshot";
          LogLevelMax = "emerg";
        };

        script =
          let
            steam_exec = "/run/current-system/sw/bin/steam";
          in
          with pkgs;
          ''
            ${coreutils}/bin/chmod -x ${steam_exec} 2&>/dev/null || true
            if pid="$(${procps}/bin/pidof steam)"; then
              ${procps}/bin/kill "$pid"
            fi
            ${coreutils}/bin/sleep 58
            ${coreutils}/bin/chmod +x ${steam_exec} 2&>/dev/null || true
          '';
      };
    };
}
