{
  config,
  lib,
  ...
}: let
  cfg = config.profiles.tailscale;
in {
  options.profiles.tailscale = with lib; {
    enable = mkEnableOption "Tailscale profile";
  };
  config = lib.mkIf cfg.enable {
    networking = {
      nameservers = ["100.100.100.100" "8.8.8.8" "1.1.1.1"];
      search = ["tiger-shark.ts.net"];
    };

    # Enable Tailscale and allow it to provision certificates to caddy
    services.tailscale = {
      enable = true;
      permitCertUid = "caddy";
    };
  };
}
