{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
let
  cfg = config.services.${namespace}.reaction;
  inherit (lib) mkEnableOption mkIf optionalAttrs;

  banFor = duration: {
    ban = {
      type = "nftables";
      options = {
        set = "web";
        action = "add";
      };
    };
    unban = {
      after = duration;
      type = "nftables";
      options = {
        set = "web";
        action = "delete";
      };
    };
  };

  caddy404Stream = domain: {
    cmd = [
      "${pkgs.bash}/bin/sh"
      "-c"
      "exec ${pkgs.coreutils}/bin/tail -Fn0 /var/log/caddy/access-${domain}.log"
    ];
    filters.not_found = {
      regex = [ ''^<ip>.*"[A-Z]+ .*" 404[ \d]*$'' ];
      actions = banFor "30d";
    };
  };
in
{
  options.services.${namespace}.reaction.enable = mkEnableOption "Reaction defaults";

  config = mkIf cfg.enable {
    services.reaction = {
      enable = true;
      runAsRoot = true;
      stopForFirewall = true;
      settings = {
        plugins = {
          virtual.systemd = false;
          ipset.enable = false;
          nftables = {
            enable = true;
            systemd = false;
          };
        };
        patterns.ip = {
          type = "ip";
          ipv6mask = 64;
          ignore = [
            "127.0.0.1"
            "::1"
          ];
        };
        streams = {
          caddy_access = {
            cmd = [
              "${pkgs.bash}/bin/sh"
              "-c"
              "exec ${pkgs.coreutils}/bin/tail -Fn0 /var/log/caddy/access-*.log"
            ];
            filters.http4xx = {
              regex = [ ''^<ip>.*"(GET|POST|OPTIONS).*" 4[0-9][0-9][ \d]*$'' ];
              retry = 5;
              retryperiod = "30s";
              actions = banFor "10m";
            };
          };
        }
        // optionalAttrs config.services.${namespace}.forgejo.enable {
          forgejo_404 = caddy404Stream config.services.${namespace}.forgejo.domain;
        }
        // optionalAttrs config.services.${namespace}.gitea.enable {
          gitea_404 = caddy404Stream config.services.${namespace}.gitea.domain;
        };
      };
    };
  };
}
