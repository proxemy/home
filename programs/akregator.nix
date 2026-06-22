{
  pkgs,
  home-manager,
  config,
  secrets,
  ...
}:
{
  home-manager.users.${secrets.username} =
    if config.hardware.graphics.enable then
      {
        home =
          let
            source_opml = builtins.toFile "feeds.opml" secrets.feeds.OPML;
            target_opml = ".local/share/akregator/data/feeds.opml";
          in
          {
            packages = [
              pkgs.kdePackages.akregator
            ];

            #file.${target_opml} = {
            #  source = source_opml;
            #  force = true;

            #  onChange = ''
            #    cp --force ${source_opml} ${target_opml}
            #    chmod u+rwx,go= ${target_opml}
            #  '';
            #};

            activation.akregator_feeds = home-manager.lib.hm.dag.entryAfter [ "writeBoudnary" ] ''
              run umask 077
              run mkdir -p $(dirname "${target_opml}") || true
              run cat "${source_opml}" > "${target_opml}"
            '';
          };

        xdg.configFile."akregatorrc" = {
          force = true;
          text = ''
            [Advanced]
            Mark Read Delay=2

            [Appearance]
            Fixed Font=monospace
            Sans Serif Font=monospace
            Serif Font=monospace
            Standard Font=monospace

            [Archive]
            ArchiveMode=limitArticleNumber

            [Browser]
            EnableJavascript=false
            LMB Behaviour=OpenInExternalBrowser

            [General]
            ArticleListFeedHeaders=
            ArticleListGroupHeaders=AAAA/wAAAAAAAAABAAAAAQAAAAMBAAAAAAAAAAAAAAAAAAAAAAAABXAAAAAEAQEAAAAAAAAAAAAAAAAAAGT/////AAAAgQAAAAAAAAAEAAAC/gAAAAEAAAAAAAAA9QAAAAEAAAAAAAABBwAAAAEAAAAAAAAAdgAAAAEAAAAAAAAD6AD/////AAAAAAAAAAAAAAAAAAAAAQ==
            PreviousNewFeaturesMD5=rMGXcQMwFu7xghlAkh4bXg==
            Show Tray Icon=false
            Show Unread In Taskbar=false
            SubscriptionListHeaders=AAAA/wAAAAAAAAABAAAAAQAAAAAAAAAAAAAAAAAAAAADBgAAAAIAAAABAAAAHAAAAAIAAABkAAABzwAAAAMBAAABAAAAAAAAAAAAAAAAZP////8AAACBAAAAAAAAAAMAAAHPAAAAAQAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAQAAAAAAAAPoAAAAAGQAAAAAAAAAAAAAAAAAAAAB
            Use Interval Fetch=false

            [HTML Settings]
            AccessKeyEnabled=false
            Fonts=monospace,monospace,monospace,monospace,monospace,monospace,0
            MediumFontSize=14
            MinimumFontSize=14

            [Network]
            Use HTML Cache=false

            [Security]
            LoadExternalReferences=false

            [View]
            Splitter 1 Sizes=479,1437
            Splitter 2 Sizes=317,634
          '';
        };
      }
    else
      { };
}
