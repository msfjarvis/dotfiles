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
    ghostty = {
      enable = true;
      settings = {
        bold-is-bright = true;
        font-family = "IosevkaTerm NFM";
        keybind = [
          "ctrl+shift+right=unbind"
          "ctrl+shift+left=unbind"
          "shift+end=unbind"
          "shift+home=unbind"
        ];
        shell-integration = "bash";
        theme = "catppuccin-mocha";
        window-width = 244;
        window-height = 58;
      };
    };
    gnome-terminal.enable = false;
    logseq.enable = true;
    mpv.enable = true;
    spotify = {
      enable = true;
      spot = false; # Audio quality is just so consistently ass cheeks
    };
    zed = {
      enable = true;
      extensions = [
        "catppuccin"
        "git-firefly"
        "html"
        "nix"
        "toml"
      ];
      userSettings = {
        assistant = {
          enabled = false;
          # Necessary for this to be parsed, see https://github.com/zed-industries/zed/issues/16839#issuecomment-2309043157
          version = "2";
        };
        autosave = {
          after_delay.milliseconds = 1000;
        };
        auto_update = false;
        base_keymap = "JetBrains";
        buffer_font_family = "IosevkaTerm Nerd Font";
        buffer_font_size = 16;
        features = {
          inline_completion_provider = "none";
        };
        indent_guides.enabled = true;
        inline_completions.disabled_globs = [ "*.md" ];
        inlay_hints = {
          enabled = false;
          show_type_hints = true;
          show_parameter_hints = true;
          show_other_hints = true;
          show_background = true;
          edit_debounce_ms = 700;
          scroll_debounce_ms = 50;
        };
        load_direnv = "shell_hook";
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
        show_inline_completions = false;
        show_wrap_guides = true;
        telemetry = {
          diagnostics = false;
          metrics = false;
        };
        terminal = {
          env = {
            GIT_EDITOR = "zeditor --wait";
          };
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
