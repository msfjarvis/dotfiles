{
  services.anubis = {
    defaultOptions = {
      enable = true;
      settings = {
        BIND_NETWORK = "tcp";
        DIFFICULTY = 5;
        METRICS_BIND_NETWORK = "tcp";
        OG_PASSTHROUGH = true;
        SERVE_ROBOTS_TXT = true;
      };
    };
  };
}
