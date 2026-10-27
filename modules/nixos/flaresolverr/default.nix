{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.flaresolverr;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (lib.${namespace}) mkTailscaleVHost ports;
in
{
  options.services.${namespace}.flaresolverr = {
    enable = mkEnableOption "FlareSolverr";
    domain = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Tailscale domain to expose the service on";
    };
  };

  config = mkIf cfg.enable {
    services.flaresolverr = {
      enable = true;
      port = lib.mkDefault ports.flaresolverr;
    };
    systemd.services.flaresolverr.environment.HOST = "127.0.0.1";

    services.caddy.virtualHosts = mkIf (cfg.domain != null) (
      mkTailscaleVHost cfg.domain ''
        reverse_proxy 127.0.0.1:${toString config.services.flaresolverr.port}
      ''
    );
  };
}
