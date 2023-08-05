{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;
    mutableExtensionsDir = false;
    extensions =
      (with pkgs.vscode-extensions; [
        arrterian.nix-env-selector
        eamodio.gitlens
        jnoortheen.nix-ide
        ms-python.python
        ms-vscode-remote.remote-ssh
        oderwat.indent-rainbow
        rust-lang.rust-analyzer
      ])
      ++ (map
        (extension:
          pkgs.vscode-utils.buildVscodeMarketplaceExtension {
            mktplcRef = {
              inherit (extension) name publisher version sha256;
            };
          })
        (import ./extensions.nix).extensions);
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
      "workbench.editor.untitled.hint" = "hidden";
      "editor.unicodeHighlight.invisibleCharacters" = false;
      "git.confirmSync" = false;
      "[json]"."editor.defaultFormatter" = "vscode.json-language-features";
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nixd";
      "nix.formatterPath" = "alejandra";
      "nix.serverSettings".nil.formatting.command = [
        "alejandra"
      ];
      "gitlens.currentLine.enabled" = false;
      "gitlens.statusBar.reduceFlicker" = false;
      "gitlens.advanced.fileHistoryFollowsRenames" = true;
      "gitlens.advanced.abbreviateShaOnCopy" = true;
      "gitlens.codeLens.enabled" = false;
      "rust-analyzer.checkOnSave" = true;
      "rust-analyzer.completion.privateEditable.enable" = true;
      "python.linting.enabled" = false;
      "python.formatting.provider" = "black";
      "python.formatting.blackPath" = "${pkgs.python311Packages.black}/bin/black";
    };
  };
}
