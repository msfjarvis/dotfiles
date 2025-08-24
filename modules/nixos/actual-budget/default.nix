{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.actual-budget;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (lib.${namespace}) ports;
in
{
  options.services.${namespace}.actual-budget = {
    enable = mkEnableOption "Actual Budget";
    domain = mkOption {
      type = types.str;
      description = "domain to expose the service on";
    };
  };
  config = mkIf cfg.enable {
    services.caddy.virtualHosts = {
      "https://${cfg.domain}" = with config.services.actual.settings; {
        extraConfig = ''
          import blackholeCrawlers
          encode gzip zstd
          reverse_proxy ${hostname}:${toString port}
        '';
      };
    };

    services.actual = {
      enable = true;
      settings = {
        hostname = "127.0.0.1";
        port = ports.actual;
      };
    };
  };
}
