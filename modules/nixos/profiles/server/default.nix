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

    # Install Ghostty's bash integration and terminfo
    environment.systemPackages = [ pkgs.ghostty.terminfo ];
    programs.bash = {
      interactiveShellInit = ''
        GHOSTTY_RESOURCES_DIR="${pkgs.ghostty.shell_integration}"
        export GHOSTTY_RESOURCES_DIR
        if [[ "$TERM" == "xterm-ghostty" ]]; then
          builtin source ${pkgs.ghostty.shell_integration}/shell-integration/bash/ghostty.bash
        fi
      '';
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
