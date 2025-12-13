{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.vaultwarden;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (lib.${namespace}) ports;
in
{
  options.services.${namespace}.vaultwarden = {
    enable = mkEnableOption "Vaultwarden";
    domain = mkOption {
      type = types.str;
      description = "Domain name to expose server on";
    };
    backvault = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Backvault backup service for Vaultwarden";
      };
      dataPath = mkOption {
        type = types.str;
        default = "/var/lib/backvault";
        description = "Path to store backvault data and backups";
      };
    };
  };
  config = mkIf cfg.enable {
    services.caddy.virtualHosts = {
      "https://${cfg.domain}" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:${builtins.toString config.services.vaultwarden.config.ROCKET_PORT} {
            header_up X-Real-IP {remote_host}
          }
        '';
      };
    };

    services.postgresql = {
      enable = true;
      ensureUsers = [
        {
          name = "vaultwarden";
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [ "vaultwarden" ];
    };

    sops.secrets.vaultwarden = {
      sopsFile = lib.snowfall.fs.get-file "secrets/vaultwarden.env";
      owner = "vaultwarden";
      group = "vaultwarden";
      format = "dotenv";
    };

    sops.secrets.backvault = mkIf cfg.backvault.enable {
      sopsFile = lib.snowfall.fs.get-file "secrets/backvault.env";
      owner = "root";
      group = "root";
      format = "dotenv";
    };
    services.vaultwarden = {
      enable = true;
      dbBackend = "postgresql";
      environmentFile = config.sops.secrets.vaultwarden.path;
      config = {
        DATABASE_URL = "postgres://vaultwarden?host=/run/postgresql";
        DOMAIN = "https://${cfg.domain}";
        EXPERIMENTAL_CLIENT_FEATURE_FLAGS = "autofill-overlay,autofill-v2,browser-fileless-import,extension-refresh,fido2-vault-credentials,inline-menu-positioning-improvements,ssh-key-vault-item,ssh-agent";
        INVITATIONS_ALLOWED = false;
        PUSH_ENABLED = true;
        PUSH_IDENTITY_URI = "https://identity.bitwarden.eu";
        PUSH_RELAY_URI = "https://api.bitwarden.eu";
        ROCKET_PORT = ports.vaultwarden;
        SIGNUPS_ALLOWED = false;
        USE_SYSLOG = true;
      };
    };

    # Backvault configuration
    virtualisation = mkIf cfg.backvault.enable {
      podman.enable = true;
      oci-containers = {
        backend = "podman";
        containers.backvault = {
          image = "ghcr.io/mvfc/backvault:latest";
          environmentFiles = [
            config.sops.secrets.backvault.path
          ];
          volumes = [
            "${cfg.backvault.dataPath}/backups:/app/backups:rw"
            "${cfg.backvault.dataPath}/db:/app/db:rw"
          ];
          ports = [
            "8080:8080/tcp"
          ];
          log-driver = "journald";
          autoStart = true;
          extraOptions = [
            "--add-host=host.docker.internal:host-gateway"
            "--network-alias=backvault"
            "--network=backvault_default"
          ];
        };
      };
    };

    systemd.services.podman-backvault = mkIf cfg.backvault.enable {
      serviceConfig = {
        Restart = lib.mkOverride 90 "always";
        RestartMaxDelaySec = lib.mkOverride 90 "1m";
        RestartSec = lib.mkOverride 90 "100ms";
        RestartSteps = lib.mkOverride 90 9;
      };
      after = [
        "podman-network-backvault_default.service"
      ];
      requires = [
        "podman-network-backvault_default.service"
      ];
      unitConfig.RequiresMountsFor = [
        "${cfg.backvault.dataPath}/backups"
        "${cfg.backvault.dataPath}/db"
      ];
    };

    systemd.services.podman-network-backvault_default = mkIf cfg.backvault.enable {
      path = [ config.virtualisation.podman.package ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStop = "${config.virtualisation.podman.package}/bin/podman network rm -f backvault_default";
      };
      script = ''
        ${config.virtualisation.podman.package}/bin/podman network inspect backvault_default || ${config.virtualisation.podman.package}/bin/podman network create backvault_default
      '';
      partOf = [ "podman-compose-backvault-root.target" ];
      wantedBy = [ "podman-compose-backvault-root.target" ];
    };

    systemd.targets.podman-compose-backvault-root = mkIf cfg.backvault.enable {
      unitConfig = {
        Description = "Root target for backvault podman compose services";
      };
    };

    # Ensure data directories exist
    systemd.tmpfiles.rules = mkIf cfg.backvault.enable [
      "d ${cfg.backvault.dataPath} 0755 root root -"
      "d ${cfg.backvault.dataPath}/backups 0755 root root -"
      "d ${cfg.backvault.dataPath}/db 0755 root root -"
    ];
  };
}
