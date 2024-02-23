_: {
  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    flags = ["--disable-up-arrow"];
    settings = {
      auto_sync = true;
      max_preview_height = 2;
      search_mode = "skim";
      show_preview = true;
      style = "compact";
      sync_frequency = "5m";
      sync_address = "http://wailord:8888";
    };
  };
}
