{ system }:
let
  enabled =
    (system.extendModules {
      modules = [
        {
          services.jarvis.pl-mail.enable = true;
        }
      ];
    }).config;
  container = enabled.virtualisation.oci-containers.containers.pl-mail;
  backend = enabled.virtualisation.oci-containers.backend;
in
assert builtins.all (item: item.assertion) enabled.assertions;
assert enabled.services.postgresql.enable;
assert builtins.elem "plmail" enabled.services.postgresql.ensureDatabases;
assert builtins.elem enabled.services.postgresql.package.pkgs.pgvector (
  enabled.services.postgresql.extensions enabled.services.postgresql.package.pkgs
);
assert enabled.users.users.plmail.isSystemUser;
assert enabled.users.users.plmail.group == "plmail";
assert container.user == null;
assert (builtins.head enabled.systemd.services."${backend}-pl-mail".path).name == backend;
assert builtins.elem "127.0.0.1:9034:8080" container.ports;
assert builtins.elem "/run/postgresql:/run/postgresql:ro" container.volumes;
assert builtins.elem "d /var/lib/pl-mail 0700 plmail plmail - -" enabled.systemd.tmpfiles.rules;
assert container.environment.APP_ALL_IN_ONE == "1";
assert container.environment.SERVER_NAME == ":8080";
assert builtins.match ".*host=%2Frun%2Fpostgresql.*" container.environment.DATABASE_URL != null;
assert builtins.elem "pl-mail-postgresql.service"
  enabled.systemd.services."${backend}-pl-mail".requires;
assert builtins.elem "pl-mail-postgresql.service"
  enabled.systemd.services."${backend}-pl-mail".after;
assert builtins.elem "postgresql-setup.service"
  enabled.systemd.services.pl-mail-postgresql.requires;
assert builtins.elem "postgresql-setup.service" enabled.systemd.services.pl-mail-postgresql.after;
assert enabled.systemd.services.pl-mail-postgresql.serviceConfig.User == "postgres";
assert
  builtins.match ".*CREATE EXTENSION IF NOT EXISTS vector.*" enabled.systemd.services.pl-mail-postgresql.script
  != null;
assert !(enabled.systemd.services ? pl-mail-db-proxy);
true
