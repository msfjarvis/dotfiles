{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.golink;
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.${namespace}) tailnetDomain;
in
{
  options.services.${namespace}.golink = {
    enable = mkEnableOption "golink, go/ links for Tailscale";
  };
  config = mkIf cfg.enable {
    sops.secrets.golink-tsauthkey = {
      sopsFile = lib.snowfall.fs.get-file "secrets/tailscale.yaml";
      owner = config.services.golink.user;
      key = "golink-tsauthkey";
      restartUnits = [ "golink.service" ];
    };
    services.golink = {
      enable = true;
      tailscaleAuthKeyFile = config.sops.secrets.golink-tsauthkey.path;
    };
    services.prometheus.scrapeConfigs = [
      {
        job_name = "golink";
        metrics_path = "/.metrics";
        scheme = "https";
        static_configs = [
          {
            targets = [ "go.${tailnetDomain}" ];
          }
        ];
      }
    ];
  };
}
