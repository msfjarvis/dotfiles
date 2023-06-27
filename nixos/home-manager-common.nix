{pkgs, ...}: {
  programs.bat = {
    enable = true;
    config = {theme = "zenburn";};
  };

  programs.bottom = {enable = true;};

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  programs.exa = {
    enable = true;
    enableAliases = true;
  };

  programs.fzf = {
    enable = true;
    defaultCommand = "fd -tf";
    defaultOptions = ["--height 40%"];
    enableBashIntegration = true;
    fileWidgetCommand = "fd -H";
    changeDirWidgetCommand = "fd -Htd";
    historyWidgetOptions = ["--sort" "--exact"];
  };

  programs.gpg = {enable = true;};

  programs.home-manager = {enable = true;};

  programs.jq = {enable = true;};

  programs.nix-index = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  systemd.user.services.optimise-nix-store = {
    Unit = {Description = "nix store maintenance";};

    Service = {
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
      ExecStart = toString (pkgs.writeShellScript "nix-optimise-store" ''
        ${pkgs.nix}/bin/nix-collect-garbage -d
        ${pkgs.nix}/bin/nix store gc
        ${pkgs.nix}/bin/nix store optimise
      '');
    };
  };

  systemd.user.timers.optimise-nix-store = {
    Unit = {Description = "nix store maintenance";};
    Timer = {OnCalendar = "weekly";};
    Install = {WantedBy = ["timers.target"];};
  };
}
