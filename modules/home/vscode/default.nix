{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.profiles.vscode;
in {
  options.profiles.vscode = with lib; {
    enable = mkEnableOption "Enable VSCode editor";
  };
  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;
      mutableExtensionsDir = false;
      extensions =
        lib.mkDefault
        ((lib.optionals pkgs.stdenv.isLinux [pkgs.vscode-extensions.rust-lang.rust-analyzer-nightly])
          ++ (with pkgs.vscode-marketplace; [
            arrterian.nix-env-selector
            eamodio.gitlens
            github.vscode-github-actions
            jnoortheen.nix-ide
            k--kato.intellij-idea-keybindings
            ms-vscode-remote.remote-ssh
            ms-vscode-remote.remote-ssh-edit
            mtdmali.daybreak-theme
            oderwat.indent-rainbow
            tamasfe.even-better-toml
          ]));
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
        "editor.suggestSelection" = "first";
        "editor.formatOnPaste" = true;
        "workbench.colorTheme" = "Daybreak";
        "explorer.confirmDelete" = false;
        "editor.fontWeight" = "500";
        "editor.renderWhitespace" = "all";
        "files.autoSave" = "afterDelay";
        "editor.fontSize" = 15;
        "[rust]"."editor.defaultFormatter" = "rust-lang.rust-analyzer";
        "editor.fontFamily" = "'JetBrainsMono Nerd Font'";
        "workbench.startupEditor" = "newUntitledFile";
        "git.autofetch" = true;
        "explorer.confirmDragAndDrop" = false;
        "git.enableSmartCommit" = true;
        "workbench.statusBar.visible" = true;
        "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font'";
        "terminal.integrated.fontSize" = 16;
        "editor.inlineSuggest.enabled" = true;
        "editor.unicodeHighlight.invisibleCharacters" = false;
        "git.confirmSync" = false;
        "[json]"."editor.defaultFormatter" = "vscode.json-language-features";
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "${lib.getExe pkgs.nil}";
        "nix.formatterPath" = "${lib.getExe pkgs.alejandra}";
        "nix.serverSettings".nil.formatting.command = [
          "${lib.getExe pkgs.alejandra}"
        ];
        "gitlens.currentLine.enabled" = false;
        "gitlens.statusBar.reduceFlicker" = false;
        "gitlens.advanced.fileHistoryFollowsRenames" = true;
        "gitlens.advanced.abbreviateShaOnCopy" = true;
        "gitlens.codeLens.enabled" = false;
        "rust-analyzer.checkOnSave" = true;
        "rust-analyzer.completion.privateEditable.enable" = true;
        "window.titleBarStyle" = "custom";
        "disable-hardware-acceleration" = true;
      };
    };
  };
}
