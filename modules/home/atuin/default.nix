{
  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      auto_sync = true;
      invert = false;
      max_preview_height = 2;
      search_mode = "fuzzy";
      show_preview = true;
      store_failed = false;
      style = "full";
      sync_frequency = "5m";
      sync_address = "http://wailord:8888";
    };
  };
}
