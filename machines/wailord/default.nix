{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    tmp.cleanOnBoot = true;
  };
  zramSwap.enable = true;

  # Enable networking
  networking = {
    hostName = "wailord";
    networkmanager.enable = true;
    nftables.enable = true;
    nameservers = ["100.100.100.100" "8.8.8.8" "1.1.1.1"];
    search = ["tiger-shark.ts.net"];
    firewall = {
      allowedTCPPorts = [
        80
        443
      ];
      allowedTCPPortRanges = [
        {
          from = 6881;
          to = 6889;
        }
      ];
    };
  };

  time.timeZone = "Asia/Kolkata";

  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkForce "us";
    useXkbConfig = true;
  };

  users = {
    mutableUsers = false;
    users = {
      msfjarvis = {
        isNormalUser = true;
        extraGroups = ["wheel"];
        hashedPassword = ''$y$j9T$g8JL/B98ogQF/ryvwHpWe.$jyKMeotGz/o8Pje.nejKzPMiYOxtn//33OzMu5bAHm2'';
        openssh.authorizedKeys.keys = [
          ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEoNv1E/D4IzNIJeJg7Rp49Jizw8aoCLSyFLcUmD1F6K''
          ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP3WC4HKwbfVGnJzhtrWo2Ue0dnaZH1JaPu4X6VILQL6''
        ];
      };
      root.openssh.authorizedKeys.keys = [
        ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEoNv1E/D4IzNIJeJg7Rp49Jizw8aoCLSyFLcUmD1F6K''
        ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP3WC4HKwbfVGnJzhtrWo2Ue0dnaZH1JaPu4X6VILQL6''
      ];
    };
  };

  programs.command-not-found.enable = false;
  programs.mosh.enable = true;

  environment.systemPackages = with pkgs; [
    git
    micro
  ];

  services.caddy = {
    enable = true;
    virtualHosts = {
      "https://git.msfjarvis.dev" = {
        extraConfig = ''
          reverse_proxy :${toString config.services.gitea.settings.server.HTTP_PORT}
        '';
      };
      # "https://til.msfjarvis.dev" = {
      #   extraConfig = ''
      #     reverse_proxy :9090
      #   '';
      # };
    };
  };

  services.gitea = {
    enable = true;
    appName = "Harsh Shandilya's Git hosting";
    settings = {
      mailer.ENABLED = false;
      server.DOMAIN = "git.msfjarvis.dev";
      server.ROOT_URL = "https://git.msfjarvis.dev/";
      service.COOKIE_SECURE = true;
      service.DISABLE_REGISTRATION = true;
    };
  };

  services.openssh.enable = true;

  services.tailscale = {
    enable = true;
    permitCertUid = "caddy";
  };

  services.tailscale-autoconnect = {
    enable = true;
    authkeyFile = "/run/secrets/tsauthkey";
    extraOptions = ["--accept-risk=lose-ssh" "--ssh"];
  };

  system.stateVersion = "23.11";

  # Workaround for https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;

  # virtualisation.oci-containers.containers = {
  #   linkding = {
  #     image = "sissbruecker/linkding:latest-alpine";
  #     ports = ["127.0.0.1:9090:9090"];
  #     volumes = ["/var/lib/linkding:/etc/linkding/data"];
  #   };
  # };

  # Disable some home-manager goodies that are pointless on servers.
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
