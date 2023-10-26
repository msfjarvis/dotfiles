{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
  ];

  boot = {
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
    tmp.cleanOnBoot = true;
  };
  zramSwap.enable = true;

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
      "https://til.msfjarvis.dev" = {
        extraConfig = ''
          reverse_proxy :${toString config.services.shiori.port}
        '';
      };
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

  services.shiori = {
    enable = true;
    port = 9999;
  };

  services.tailscale = {
    enable = true;
    permitCertUid = "caddy";
  };

  services.tailscale-autoconnect = {
    enable = true;
    authkeyFile = config.age.secrets.wailord-tsauthkey.path;
    extraOptions = ["--accept-risk=lose-ssh" "--ssh"];
  };

  system.stateVersion = "23.11";

  # Workaround for https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
}
