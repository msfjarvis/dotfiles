{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.phanpy;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.services.${namespace}.phanpy = {
    enable = mkEnableOption "phanpy, a fediverse client";
    domain = mkOption {
      type = types.str;
      description = "Domain name to expose server on";
    };
  };
  config = mkIf cfg.enable {
    # environment.etc.<name>.source typically only accepts individual files
    # but we want to send over the whole Phanpy folder, the trailing `/*`
    # enables that. Saw it somewhere on the NixOS forums but I no longer
    # can summon the search query that took me there.
    environment.etc."phanpy".source = "${pkgs.${namespace}.phanpy}/*";

    services.caddy.virtualHosts = {
      "https://${cfg.domain}" = {
        extraConfig = ''
          import blackholeCrawlers
          root * /etc/phanpy/
          file_server
        '';
      };
    };
  };
}
