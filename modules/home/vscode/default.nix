{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.profiles.vscode;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.profiles.vscode = {
    enable = mkEnableOption "Enable VSCode editor";
  };
  config = mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;
      mutableExtensionsDir = false;
      extensions = lib.mkDefault (
        (lib.optionals pkgs.stdenv.isLinux [ pkgs.vscode-extensions.rust-lang.rust-analyzer-nightly ])
        ++ (with pkgs.vscode-marketplace; [
          arrterian.nix-env-selector
          catppuccin.catppuccin-vsc-icons
          eamodio.gitlens
          github.copilot
          github.copilot-chat
          github.vscode-github-actions
          jnoortheen.nix-ide
          k--kato.intellij-idea-keybindings
          ms-vscode-remote.remote-ssh
          ms-vscode-remote.remote-ssh-edit
          oderwat.indent-rainbow
          tamasfe.even-better-toml
          (pkgs.catppuccin-vsc.override {
            accent = "mauve";
            boldKeywords = true;
            italicComments = true;
            italicKeywords = true;
            extraBordersEnabled = false;
            workbenchMode = "default";
            bracketMode = "rainbow";
            colorOverrides = { };
            customUIColors = { };
          })
        ])
      );
      userSettings = {
        "files.exclude" = {
          "**/.classpath" = true;
          "**/.project" = true;
          "**/.settings" = true;
          "**/.factorypath" = true;
          venv = true;
        };
        "editor.fontLigatures" = true;
        "editor.tabSize" = 4;
        "editor.insertSpaces" = true;
        "editor.detectIndentation" = true;
        "editor.semanticHighlighting.enabled" = true;
        "editor.suggestSelection" = "first";
        "editor.formatOnPaste" = true;
        "disable-hardware-acceleration" = true;
        "editor.inlineSuggest.enabled" = true;
        "editor.unicodeHighlight.invisibleCharacters" = false;
        "explorer.confirmDelete" = false;
        "explorer.confirmDragAndDrop" = false;
        "editor.fontFamily" = "'JetBrainsMono Nerd Font'";
        "editor.fontSize" = 15;
        "editor.fontWeight" = "500";
        "editor.renderWhitespace" = "all";
        "files.autoSave" = "afterDelay";
        "git.autofetch" = true;
        "git.confirmSync" = false;
        "git.enableSmartCommit" = true;
        "gitlens.advanced.abbreviateShaOnCopy" = true;
        "gitlens.advanced.fileHistoryFollowsRenames" = true;
        "gitlens.codeLens.enabled" = false;
        "gitlens.currentLine.enabled" = false;
        "gitlens.statusBar.reduceFlicker" = false;
        "[json]"."editor.defaultFormatter" = "vscode.json-language-features";
        "nix.enableLanguageServer" = true;
        "nix" = {
          "enableLanguageServer" = true;
          "formatterPath" = "${lib.getExe pkgs.nixfmt-rfc-style}";
          "serverPath" = "${lib.getExe pkgs.nixd}";
          "serverSettings".nil.formatting.command = [ "${lib.getExe pkgs.nixfmt-rfc-style}" ];
          "serverSettings" = {
            nixd = {
              formatting.command = [ "${lib.getExe pkgs.nixfmt-rfc-style}" ];
              options = {
                "nixos" = {
                  "expr" = "(builtins.getFlake ./.).nixosConfigurations.ryzenbox.options";
                };
                "home-manager" = {
                  "expr" = "(builtins.getFlake ./.).homeConfigurations.msfjarvis@ryzenbox.options";
                };
              };
            };
          };
        };
        "[rust]"."editor.defaultFormatter" = "rust-lang.rust-analyzer";
        "rust-analyzer.checkOnSave" = true;
        "rust-analyzer.completion.privateEditable.enable" = true;
        "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font'";
        "terminal.integrated.fontSize" = 16;
        "terminal.integrated.minimumContrastRatio" = 1;
        "window.titleBarStyle" = "custom";
        "workbench.colorTheme" = "Catppuccin Mocha";
        "workbench.iconTheme" = "catppuccin-mocha";
        "workbench.startupEditor" = "newUntitledFile";
        "workbench.statusBar.visible" = true;
      };
    };
  };
}
