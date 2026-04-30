{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.iocaine;
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.${namespace}) ports;
in
{
  options.services.${namespace}.iocaine = {
    enable = mkEnableOption "iocaine AI crawler trap";
  };

  config = mkIf cfg.enable {
    services.iocaine = {
      enable = true;
      config = {
        server.default = {
          bind = "127.0.0.1:${toString ports.iocaine}";
          mode = "http";
          use.handler-from = "default";
        };
        handler.default = { };
      };
    };

    services.caddy.extraConfig = lib.mkAfter ''
      (iocaine) {
        @read method GET HEAD
        reverse_proxy @read 127.0.0.1:${toString ports.iocaine} {
          @fallback status 421
          handle_response @fallback
        }
      }
    '';
  };
}
