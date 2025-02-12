{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.profiles.${namespace}.server;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.profiles.${namespace}.server = {
    enable = mkEnableOption "server profile";
    tailscaleExitNode = mkEnableOption "Run this machine as a Tailscale exit node";
  };
  config = mkIf cfg.enable {
    # Enable Tailscale
    profiles.${namespace}.tailscale.enable = true;

    # Disable a bunch of stuff that's unnecessary on servers
    documentation = {
      enable = false;
      info.enable = false;
      doc.enable = false;
      nixos.enable = false;
    };
    environment.stub-ld.enable = lib.mkForce false;
    programs.less.lessopen = lib.mkForce null;
    programs.nano.enable = false;
    fonts.fontconfig.enable = false;
    xdg = {
      autostart.enable = false;
      icons.enable = false;
      menus.enable = false;
      mime.enable = false;
      sounds.enable = false;
    };
    services.logrotate.enable = false;
    services.udisks2.enable = false;
    boot.bcache.enable = false;
    appstream.enable = false;
    powerManagement.enable = false;

    networking = {
      networkmanager.enable = lib.mkDefault true;
      networkmanager.plugins = lib.mkForce [ ];
      nftables.enable = true;
      firewall = {
        # Open HTTP(S) ports
        allowedTCPPorts = [
          80
          443
        ];
        # Torrent clients
        allowedTCPPortRanges = [
          {
            from = 6881;
            to = 6889;
          }
        ];
      };
    };

    console = {
      font = "Lat2-Terminus16";
      keyMap = lib.mkForce "us";
      useXkbConfig = true;
    };

    # Automatically log into my user account
    services.getty.autologinUser = lib.mkForce "msfjarvis";

    # Enable SSH
    programs.mosh.enable = true;
    services.openssh = {
      enable = true;
      package = pkgs.openssh_hpn;
      settings = {
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
      };
    };
    users.users.root.openssh.authorizedKeys.keys = [
      ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOZFw0Dgs0z29Brvj+CejlgBG5t0AtoFvNIjd3DPvL7N''
    ];

    sops.secrets.server-tsauthkey = {
      sopsFile = lib.snowfall.fs.get-file "secrets/tailscale.yaml";
    };
    services.tailscale = {
      authKeyFile = config.sops.secrets.server-tsauthkey.path;
      extraUpFlags = [
        "--accept-risk=lose-ssh"
        "--ssh"
      ] ++ lib.optionals cfg.tailscaleExitNode [ "--advertise-exit-node" ];
      useRoutingFeatures = if cfg.tailscaleExitNode then "both" else "client";
    };
  };
}
