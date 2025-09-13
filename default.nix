let
  inherit (builtins) currentSystem fromJSON readFile;

  # Copied from https://github.com/edolstra/flake-compat/pull/44/files
  fetchurl =
    { url, sha256 }:
    derivation {
      builder = "builtin:fetchurl";

      name = "source";
      inherit url;

      outputHash = sha256;
      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
      executable = false;
      unpack = false;

      system = "builtin";

      # No need to double the amount of network traffic
      preferLocalBuild = true;

      impureEnvVars = [
        # We borrow these environment variables from the caller to allow
        # easy proxy configuration.  This is impure, but a fixed-output
        # derivation like fetchurl is allowed to do so since its result is
        # by definition pure.
        "http_proxy"
        "https_proxy"
        "ftp_proxy"
        "all_proxy"
        "no_proxy"
      ];

      # To make "nix-prefetch-url" work.
      urls = [ url ];
    };

  getFlake =
    name: with (fromJSON (readFile ./flake.lock)).nodes.${name}.locked; {
      inherit rev;
      outPath = fetchTarball {
        url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
        sha256 = narHash;
      };
    };
  getRawFlake =
    name: with (fromJSON (readFile ./flake.lock)).nodes.${name}.locked; {
      inherit rev;
      outPath = fetchurl {
        inherit url;
        sha256 = narHash;
      };
    };
in
{
  system ? currentSystem,
  pkgs ? import (getFlake "nixpkgs") {
    localSystem = {
      inherit system;
    };
  },
  fenix ? getFlake "fenix",
  rust-manifest ? getRawFlake "rust-manifest",
}:
let
  callPackage = pkg: pkgs.callPackage pkg;
in
{
  adb-sync = callPackage ./packages/adb-sync { };
  adbear = callPackage ./packages/adbear {
    inputs = {
      inherit fenix rust-manifest;
    };
  };
  adbtuifm = callPackage ./packages/adbtuifm { };
  adx = callPackage ./packages/adx { };
  age-keygen-deterministic = callPackage ./packages/age-keygen-deterministic { };
  boop-gtk = callPackage ./packages/boop-gtk { };
  caddy-with-plugins = callPackage ./packages/caddy-with-plugins { };
  clipboard-substitutor = callPackage ./packages/clipboard-substitutor { };
  cyberdrop-dl = callPackage ./packages/cyberdrop-dl { };
  dependency-watch = callPackage ./packages/dependency-watch { };
  diffuse-bin = callPackage ./packages/diffuse-bin { };
  gallery-dl-unstable = callPackage ./packages/gallery-dl-unstable { };
  gdrive = callPackage ./packages/gdrive { };
  gitice = callPackage ./packages/gitice {
    inputs = {
      inherit fenix rust-manifest;
    };
  };
  gitout = callPackage ./packages/gitout { };
  glance = callPackage ./packages/glance { };
  gphotos-cdp = callPackage ./packages/gphotos-cdp { };
  hcctl = callPackage ./packages/hcctl { };
  healthchecks-monitor = callPackage ./packages/healthchecks-monitor { };
  katbin = callPackage ./packages/katbin { };
  linkleaner = callPackage ./packages/linkleaner { };
  mediafire_rs = callPackage ./packages/mediafire_rs { };
  patreon-dl = callPackage ./packages/patreon-dl { };
  phanpy = callPackage ./packages/phanpy { };
  pidcat = callPackage ./packages/pidcat { };
  prometheus-qbittorrent-exporter = callPackage ./packages/prometheus-qbittorrent-exporter { };
  rucksack = callPackage ./packages/rucksack { };
  toml-cli = callPackage ./packages/toml-cli { };
}
