# Disable some home-manager goodies that are pointless on servers.
_: {
  home-manager.users.msfjarvis = {
    home.file.".imwheelrc".enable = false;
    programs.browserpass.enable = false;
    programs.password-store.enable = false;
    programs.topgrade.enable = false;
    programs.vscode.enable = false;
    services.git-sync.enable = false;

    # Use a simpler prompt.
    programs.starship = {
      settings = {
        format = "$directory$git_branch$git_state$git_status➜ ";
        character.disabled = true;
      };
    };
  };
}
