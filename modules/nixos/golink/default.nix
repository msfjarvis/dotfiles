{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.golink;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.services.${namespace}.golink = {
    enable = mkEnableOption "golink, go/ links for Tailscale";
  };
  config = mkIf cfg.enable {
    sops.secrets.golink-tsauthkey = {
      sopsFile = lib.snowfall.fs.get-file "secrets/tailscale.yaml";
      owner = config.services.golink.user;
      key = "services-tsauthkey-env";
      restartUnits = [ "golink.service" ];
    };
    services.golink = {
      enable = true;
    };
    systemd.services.golink.serviceConfig.EnvironmentFile = config.sops.secrets.golink-tsauthkey.path;
  };
}
