{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.ncps;
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.${namespace}) ports;
in
{
  options.services.${namespace}.ncps = {
    enable = mkEnableOption "ncps, a Nix binary cache proxy";
  };
  config = mkIf cfg.enable {
    sops.secrets.ncps-private-key = {
      sopsFile = lib.snowfall.fs.get-file "secrets/ncps.yaml";
    };
    services.ncps = {
      enable = true;
      logLevel = "info";
      server = {
        addr = "127.0.0.1:${toString ports.ncps}";
      };
      cache = {
        allowDeleteVerb = false;
        allowPutVerb = false;
        hostName = "0.0.0.0";
        maxSize = "50G";
        secretKeyPath = config.sops.secrets.ncps-private-key.path;
        lru = {
          scheduleTimeZone = "Asia/Kolkata";
          # 8 AM every day
          schedule = "00 08 * * *";
        };
      };
      upstream = {
        caches = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
          "https://nix-cache.tiger-shark.ts.net/aarch64-linux"
          "https://nix-cache.tiger-shark.ts.net/x86_64-linux"
        ];
        publicKeys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "aarch64-linux:n1uEEJsd/qjPYB1G3jUEW1oyia8O9rTCJKpCLgPW2gM="
          "x86_64-linux:XrBbCCueC9hO05zf8GjmK1/YtHuZwqwcgx0pkHWLgvM="
        ];
      };
    };
    nix.settings = {
      substituters = lib.mkForce [
        "http://${config.services.ncps.server.addr}"
      ];
      trusted-public-keys = lib.mkForce [
        "0.0.0.0-1:vGt+NL767D+cNfJMnpyqquPZHmnOrrK8p6l2c3vicfs="
      ];
    };
  };
}
