{host, ...}: {
  programs.browserpass = {
    enable = host == "ryzenbox";
    browsers = ["firefox"];
  };
}
