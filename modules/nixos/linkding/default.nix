{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.linkding;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (lib.${namespace}) ports;
in
{
  options.services.${namespace}.linkding = {
    enable = mkEnableOption "Linkding bookmark manager";
    domain = mkOption {
      type = types.str;
      default = "links.msfjarvis.dev";
      description = "Domain name to expose Linkding on";
    };
    settings = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Additional Linkding LD_* settings";
    };
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."https://${cfg.domain}" = {
      logFormat = lib.${namespace}.mkReactionLogFormat cfg.domain;
      extraConfig = ''
        import blackholeCrawlers
        reverse_proxy ${config.services.linkding.address}:${toString config.services.linkding.port} {
          header_up X-Real-IP {remote_host}
        }
      '';
    };

    services.linkding = {
      enable = true;
      address = "127.0.0.1";
      port = ports.linkding;
      database = {
        type = "postgres";
        createLocally = true;
      };
      settings = {
        LD_CSRF_TRUSTED_ORIGINS = "https://${cfg.domain}";
      }
      // cfg.settings;
    };
  };
}
