{
  lib,
  config,
  self,
  cfg,
  secrets,
  ...
}:
let
  provider = config.systemd.services.ollama;
in
{
  services.open-webui = {
    enable = true;
    openFirewall = true;
  };

  nixpkgs.config.allowUnfreePackages = [ "open-webui" ];

  systemd.services.open-webui = {
    requires =
      assert provider.enable;
      [ provider.name ];
    wantedBy = lib.mkForce [ ]; # remove multi-user.target to disable autostart

    environment = {
      GLOBAL_LOG_LEVEL = if cfg.debug then "INFO" else "ERROR";
      LOG_LEVEL = if cfg.debug then "INFO" else "ERROR";
      FFLINE_MODE = "True";
      HF_HUB_OFFLINE = "True";

      RAG_EMBEDDING_ENGINE = "ollama";
      RAG_EMBEDDING_MODEL = "nomic-embed-text"; # "all-minilm"; "nomic-embed-text"; "mxbai-embed-large";
      RAG_EMBEDDING_MODEL_AUTO_UPDATE = "False";
      RAG_RERANKING_MODEL_AUTO_UPDATE = "False";
      WHISPER_MODEL_AUTO_UPDATE = "False";

      #CORS_ALLOW_ORIGIN = "http://${config.services.open-webui.host}";

      WEBUI_ADMIN_EMAIL = "${secrets.username}@a.b";
      WEBUI_ADMIN_PASSWORD = secrets.username;
      WEBUI_ADMIN_NAME = secrets.username;
      ENABLE_SIGNUP = "False";

      ENABLE_KB_EXEC = "True";
      ENABLE_CALENDAR = "False";
      ENABLE_CHANNELS = "False";
      ENABLE_AUTOMATIONS = "False";
      ENABLE_SUBAGENTS = "False";
      ENABLE_EASTER_EGGS = "False";

      USE_CUDA = "True";
      DEVICE_TYPE = "cuda";
    };

    serviceConfig = (import "${self}/lib/mk_systemd_service.nix" {
      MemoryDenyWriteExecute = lib.mkForce true;
    });
  };

  systemd.sockets.open-webui = {
      wantedBy = [ "sockets.target" ];
      socketConfig = {
        # open-webui is not trivially able the take over a connection fd
        # tries to bind to 8080 directly.
        ListenStream = config.services.open-webui.port + 1;
        Accept = false;
        #BindToDevice = "lo";
        IPAddressAllow = [ "127.0.0.1" ] ++ secrets.list_of.ips;
        IPAddressDeny = "any";
      };
    };
}
