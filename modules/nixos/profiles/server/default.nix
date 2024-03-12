{
  config,
  lib,
  ...
}: let
  cfg = config.profiles.server;
in {
  options.profiles.server = with lib; {
    enable = mkEnableOption "server profile";
  };
  config = lib.mkIf cfg.enable {
    # Enable Tailscale
    profiles.tailscale.enable = true;

    # Open HTTP(S) ports
    networking = {
      networkmanager.enable = lib.mkDefault true;
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
    sops.age.sshKeyPaths = lib.mkForce ["/etc/ssh/ssh_host_ed25519_key"];
    sops.gnupg.sshKeyPaths = lib.mkForce [];
    sops.defaultSopsFile = ./../../../../secrets/tailscale.yaml;
    sops.secrets.tsauthkey = {};

    # Automatically log into my user account
    services.getty.autologinUser = lib.mkForce "msfjarvis";

    # Enable SSH
    services.openssh.enable = true;

    # Allow Tailscale to provision certs to caddy
    services.tailscale = {
      permitCertUid = "caddy";
    };
    services.tailscale-autoconnect = {
      enable = true;
      authkeyFile = "/run/secrets/tsauthkey";
      extraOptions = ["--accept-risk=lose-ssh" "--ssh"];
    };
  };
}
