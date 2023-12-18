_: {
  programs.starship = {
    settings = {
      format = "$directory$git_branch$git_state$git_status➜ ";
      character.disabled = true;
    };
  };
}
