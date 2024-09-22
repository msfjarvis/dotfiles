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

    # Open HTTP(S) ports
    networking = {
      networkmanager.enable = lib.mkDefault true;
      networkmanager.plugins = lib.mkForce [ ];
      nftables.enable = true;
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

    # Automatically log into my user account
    services.getty.autologinUser = lib.mkForce "msfjarvis";

    # Enable SSH
    programs.mosh.enable = true;
    services.openssh = {
      enable = true;
      package = pkgs.openssh_hpn;
    };
    users.users.root.openssh.authorizedKeys.keys = [
      ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOZFw0Dgs0z29Brvj+CejlgBG5t0AtoFvNIjd3DPvL7N''
    ];

    sops.secrets.tsauthkey = {
      sopsFile = lib.snowfall.fs.get-file "secrets/tailscale.yaml";
    };
    services.tailscale = {
      authKeyFile = config.sops.secrets.tsauthkey.path;
      extraUpFlags = [
        "--accept-risk=lose-ssh"
        "--ssh"
      ] ++ lib.optionals cfg.tailscaleExitNode [ "--advertise-exit-node" ];
      useRoutingFeatures = if cfg.tailscaleExitNode then "both" else "client";
    };
  };
}
