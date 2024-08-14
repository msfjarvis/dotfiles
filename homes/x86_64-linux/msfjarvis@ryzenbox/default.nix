{
  pkgs,
  lib,
  inputs,
  namespace,
  ...
}:
{
  snowfallorg.user = {
    enable = true;
    name = "msfjarvis";
  };

  profiles.${namespace} = {
    logseq.enable = true;
    mpv.enable = true;
    pass.enable = true;
    spotify.enable = true;
    wezterm.enable = true;
    zed = {
      enable = true;
      extraPackages = with pkgs; [
        # Nix
        nixd
      ];
      extensions = [
        "catppuccin"
        "html"
        "nix"
        "toml"
      ];
      userSettings = {
        theme = "Catppuccin Mocha - No Italics";
        ui_font_size = 16;
        buffer_font_size = 16;
        show_wrap_guides = true;
        indent_guides.enabled = true;
        toolbar = {
          breadcrumbs = true;
          quick_actions = true;
          selections_menu = true;
        };
        inlayHints = {
          maxLength = null;
          lifetimeElisionHints = {
            useParameterNames = true;
            enable = "skip_trivial";
          };
          closureReturnTypeHints = {
            enable = true;
          };
        };
        lsp = {
          rust-analyzer = {
            binary.path = "${lib.getExe inputs.fenix.packages.${pkgs.stdenv.system}.rust-analyzer}";
          };
        };
      };
    };
  };

  home.stateVersion = "21.05";
}
