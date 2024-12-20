{
  lib,
  pkgs,
  namespace,
  ...
}:
{
  snowfallorg.user = {
    enable = true;
    name = "msfjarvis";
  };

  profiles.${namespace} = {
    gnome-terminal.enable = true;
    logseq.enable = true;
    mpv.enable = true;
    spotify = {
      enable = false;
      spot = false; # Audio quality is just so consistently ass cheeks
    };
    zed = {
      enable = true;
      extensions = [
        "catppuccin"
        "html"
        "nix"
        "toml"
      ];
      userSettings = {
        autosave = {
          after_delay.milliseconds = 1000;
        };
        auto_update = false;
        base_keymap = "JetBrains";
        buffer_font_family = "IosevkaTerm Nerd Font";
        buffer_font_size = 16;
        load_direnv = "shell_hook";
        indent_guides.enabled = true;
        inline_completions.disabled_globs = [ "*.md" ];
        inlay_hints = {
          enabled = true;
          show_type_hints = true;
          show_parameter_hints = true;
          show_other_hints = true;
          show_background = true;
          edit_debounce_ms = 700;
          scroll_debounce_ms = 50;
        };
        lsp = {
          nil = {
            binary.path = "${lib.getExe pkgs.nil}";
            settings = {
              formatting.command = [ "${lib.getExe pkgs.nixfmt-rfc-style}" ];
              nix = {
                flake = {
                  autoArchive = true;
                  autoEvalInputs = false;
                  nixpkgsInputName = "nixpkgs";
                };
                maxMemoryMB = 8192;
              };
            };
          };
        };
        show_wrap_guides = true;
        telemetry = {
          diagnostics = false;
          metrics = false;
        };
        theme = "Catppuccin Mocha - No Italics";
        toolbar = {
          breadcrumbs = true;
          quick_actions = true;
          selections_menu = true;
        };
        ui_font_size = 16;
      };
    };
  };

  home.stateVersion = "21.05";
}
