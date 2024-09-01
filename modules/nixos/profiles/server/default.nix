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
    services.${namespace}.tailscale-autoconnect = {
      enable = true;
      authkeyFile = config.sops.secrets.tsauthkey.path;
      extraOptions = [
        "--accept-risk=lose-ssh"
        "--ssh"
      ] ++ lib.optionals cfg.tailscaleExitNode [ "--advertise-exit-node" ];
    };

    boot.kernel.sysctl =
      if cfg.tailscaleExitNode then
        {
          "net.ipv4.ip_forward" = 1;
          "net.ipv6.conf.all.forwarding" = 1;
        }
      else
        { };
  };
}
