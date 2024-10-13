{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
let
  cfg = config.profiles.${namespace}.tailscale;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.profiles.${namespace}.tailscale = {
    enable = mkEnableOption "Tailscale profile";
  };
  config = mkIf cfg.enable {
    networking = {
      nameservers = [
        "100.100.100.100"
        "8.8.8.8"
        "1.1.1.1"
      ];
      search = [ "tiger-shark.ts.net" ];
    };

    # Enable Tailscale and allow it to provision certificates to caddy
    services.tailscale = {
      enable = true;
      permitCertUid = "caddy";
      useRoutingFeatures = lib.mkDefault "client";
    };

    users.users.msfjarvis.packages = with pkgs; [ tailscale ];
  };
}
