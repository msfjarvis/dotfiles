{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.profiles.${namespace}.server;
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
  inherit (lib.${namespace}) ports;
in
{
  options.profiles.${namespace}.server = {
    enable = mkEnableOption "server profile";
    adapterName = mkOption {
      type = types.str;
      description = "Name of the network adapter to configure for exit node performance";
    };
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
    stylix.enable = false;

    environment.systemPackages = [
      pkgs.${namespace}.gdrive
    ];

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
          ports.torrent_range
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
      ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHEykZdEDb8opMyzQMWei91G8+haD1KLhttjNLVOoSPw''
    ];

    # Enable passwordless sudo.
    security.sudo.extraRules = [
      {
        groups = [ "wheel" ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];

    sops.secrets.server-tsauthkey = {
      sopsFile = lib.snowfall.fs.get-file "secrets/tailscale.yaml";
      owner = "msfjarvis";
    };
    services.tailscale = {
      authKeyFile = config.sops.secrets.server-tsauthkey.path;
      extraUpFlags = [
        "--accept-risk=lose-ssh"
        "--ssh"
        "--accept-dns=false" # I don't want my servers to use NextDNS
      ] ++ lib.optionals cfg.tailscaleExitNode [ "--advertise-exit-node" ];
      useRoutingFeatures = if cfg.tailscaleExitNode then "both" else "client";
    };

    services.networkd-dispatcher = lib.mkIf cfg.tailscaleExitNode {
      enable = true;
      rules."50-tailscale" = {
        onState = [ "routable" ];
        script = ''
          #!${pkgs.runtimeShell}
          ${lib.getExe pkgs.ethtool} -K ${cfg.adapterName} rx-udp-gro-forwarding on rx-gro-list off
        '';
      };
    };
  };
}
