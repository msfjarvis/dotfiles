{ config, lib, ... }:
let
  cfg = config.profiles.server;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.profiles.server = {
    enable = mkEnableOption "server profile";
    tailscaleExitNode = mkEnableOption "Run this machine as a Tailscale exit node";
  };
  config = mkIf cfg.enable {
    # Enable Tailscale
    profiles.tailscale.enable = true;

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

    # Enable SOPS, force it to be age-only
    sops.age.sshKeyPaths = lib.mkForce [ "/etc/ssh/ssh_host_ed25519_key" ];
    sops.gnupg.sshKeyPaths = lib.mkForce [ ];
    sops.defaultSopsFile = lib.snowfall.fs.get-file "secrets/tailscale.yaml";
    sops.secrets.tsauthkey = { };

    # Automatically log into my user account
    services.getty.autologinUser = lib.mkForce "msfjarvis";

    # Enable SSH
    programs.mosh.enable = true;
    services.openssh.enable = true;

    services.tailscale-autoconnect = {
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
