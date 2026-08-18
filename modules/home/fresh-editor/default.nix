{ pkgs, namespace, ... }: {
  programs.fresh-editor = {
    enable = true;
    package = pkgs.${namespace}.fresh-editor;
    defaultEditor = true;
    settings = {
      tab_size = 2;
      line_numbers = true;
    };
    extraPackages = with pkgs; [
      astro-language-server
      marksman
      taplo
    ];
  };
}
