{ pkgs, inputs, ... }:
{
  snowfallorg.user = {
    enable = true;
    name = "msfjarvis";
  };

  profiles.logseq.enable = true;
  profiles.mpv.enable = true;
  profiles.pass.enable = true;
  profiles.spotify.enable = true;
  profiles.zed = {
    enable = true;
    extraPackages = with pkgs; [
      # Nix
      nixd
      # Rust
      inputs.fenix.packages.${system}.rust-analyzer
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
    };
  };

  home.stateVersion = "21.05";
}
