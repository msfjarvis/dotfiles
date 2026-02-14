{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.services.${namespace}.geoipupdate;
  inherit (lib)
    mkEnableOption
    mkIf
    ;
in
{
  options.services.${namespace}.geoipupdate = {
    enable = mkEnableOption "Automatically updating MaxMind GeoIP database";
  };
  config = mkIf cfg.enable {
    sops.secrets.geoipupdate-license = {
      sopsFile = lib.snowfall.fs.get-file "secrets/maxmind-geoip.txt";
      format = "binary";
    };
    services = {
      geoipupdate = {
        enable = true;

        settings = {
          AccountID = 1298366;

          EditionIDs = [
            "GeoLite2-ASN"
            "GeoLite2-City"
            "GeoLite2-Country"
          ];

          LicenseKey = config.sops.secrets.geoipupdate-license.path;
        };
      };

      caddy.extraConfig = ''
        (geoblock) {
          @geoblock {
            maxmind_geolocation {
              db_path "${config.services.geoipupdate.settings.DatabaseDirectory}/GeoLite2-Country.mmdb"
              deny_countries CN VN
            }
          }

          respond @geoblock "Access Denied" 403 {
            close
          }
        }
      '';
    };
  };
}
