{ system }:
let
  inherit (system) config;
  domain = config.services.jarvis.forgejo.domain;
  caddyConfig = config.services.caddy.virtualHosts."https://${domain}".extraConfig;
  userAgentPattern = builtins.elemAt (builtins.split "`" caddyConfig) 2;
  allowed = agent: builtins.match userAgentPattern agent != null;
in
assert allowed "curl/8.23.0 Nixpkgs/26.11";
assert allowed "curl/8.23.0 Lix/2.95.4";
assert allowed "Nix/2.24.0";
assert !(allowed "curl/8.23.0");
assert !(allowed "Mozilla/5.0");
assert !(allowed "FakeNix/2.0");
true
