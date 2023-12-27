{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.profiles.server;
in {
  options.profiles.server = with lib; {
    enable = mkEnableOption "server profile";
  };
  config = lib.mkIf cfg.enable {
    # Open HTTP(S) ports, setup Tailscale-aware networking
    networking = {
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

    # Enable SOPS, force it to be age-only
    sops.age.sshKeyPaths = lib.mkForce ["/etc/ssh/ssh_host_ed25519_key"];
    sops.gnupg.sshKeyPaths = lib.mkForce [];
    sops.defaultSopsFile = ./../../../secrets/tailscale.yaml;
    sops.secrets.tsauthkey = {};

    # Automatically log into my user account
    services.getty.autologinUser = "msfjarvis";

    # Enable SSH
    services.openssh.enable = true;

    # Enable Tailscale and allow it to provision certificates to caddy
    services.tailscale = {
      enable = true;
      permitCertUid = "caddy";
    };
    services.tailscale-autoconnect = {
      enable = true;
      authkeyFile = "/run/secrets/tsauthkey";
      extraOptions = ["--accept-risk=lose-ssh" "--ssh"];
    };
  };
}
