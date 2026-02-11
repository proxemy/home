{
  pkgs,
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
            local_dir = ".local/share/akregator/";
          in
          {
            packages = [
              pkgs.kdePackages.akregator
            ];

            file."${local_dir}/feeds.link" =
              let
                source_opml = builtins.toFile "feeds.opml" secrets.feeds.OPML;
                target_opml = "${local_dir}/data/feeds.opml";
              in
              {
                # akregator writes to the feeds.opml, copying it then.
                source = source_opml;
                #target = target_opml;
                force = true;
                onChange = ''
                  cp --force ${source_opml} ${target_opml}
                  chmod a=,u+rwx ${target_opml}
                '';
              };
          };

        xdg.configFile."akregatorrc" = {
          force = true;
          text = ''
            [Advanced]
            Mark Read Delay=1

            [Appearance]
            Fixed Font=monospace
            Sans Serif Font=Sans
            Serif Font=Sans
            Standard Font=Sans

            [Archive]
            ArchiveMode=limitArticleNumber

            [Browser]
            EnableJavascript=false
            LMB Behaviour=OpenInExternalBrowser

            [General]
            ArticleListFeedHeaders=AAAA/wAAAAAAAAABAAAAAQAAAAMBAAAAAAAAAAAAAAAEAgAAAAEAAAABAAAAZAAABY0AAAAEAQEAAAAAAAAAAAAAAAAAAGT/////AAAAgQAAAAAAAAAEAAAEswAAAAEAAAAAAAAAAAAAAAEAAAAAAAAAZAAAAAEAAAAAAAAAdgAAAAEAAAAAAAAD6AAAAABkAAAAAAAAAAAAAAAAAAAAAQ==
            ArticleListGroupHeaders=AAAA/wAAAAAAAAABAAAAAQAAAAMBAAAAAAAAAAAAAAAAAAAAAAAABiYAAAAEAQEAAAAAAAAAAAAAAAAAAGT/////AAAAgQAAAAAAAAAEAAAE6AAAAAEAAAAAAAAAZAAAAAEAAAAAAAAAZAAAAAEAAAAAAAAAdgAAAAEAAAAAAAAD6AD/////AAAAAAAAAAAAAAAAAAAAAQ==
            PreviousNewFeaturesMD5=rMGXcQMwFu7xghlAkh4bXg==
            Show Tray Icon=false
            Show Unread In Taskbar=false
            SubscriptionListHeaders=AAAA/wAAAAAAAAABAAAAAQAAAAAAAAAAAAAAAAAAAAADBgAAAAIAAAABAAAAHAAAAAIAAABkAAABrAAAAAMBAAABAAAAAAAAAAAAAAAAZP////8AAACBAAAAAAAAAAMAAAGsAAAAAQAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAQAAAAAAAAPoAAAAAGQAAAAAAAAAAAAAAAAAAAAB
            Use Interval Fetch=false

            [HTML Settings]
            AccessKeyEnabled=false
            Fonts=Sans,monospace,Sans,Sans,Sans,Sans,0
            MediumFontSize=14
            MinimumFontSize=12

            [Network]
            Use HTML Cache=false

            [Security]
            LoadExternalReferences=false

            [View]
            Splitter 1 Sizes=430,1486
            Splitter 2 Sizes=321,630
          '';
        };
      }
    else
      { };
}
