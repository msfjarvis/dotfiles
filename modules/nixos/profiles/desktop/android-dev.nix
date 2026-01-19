{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.profiles.${namespace}.desktop;
  defaultJdk = pkgs.zulu25;
  toolchains = [
    pkgs.zulu11
    pkgs.zulu17
    defaultJdk
  ];
  # deadnix: skip
  mapOpenJdk = pkg: "${pkg}/lib/openjdk";
  mapZuluJdk = pkg: "${pkg}/";
  mapJdk = mapZuluJdk;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.profiles.${namespace}.desktop.android-dev = {
    enable = mkEnableOption "Configure a development environment for Android apps";
  };
  config = mkIf cfg.android-dev.enable {
    users.users.msfjarvis.packages = with pkgs; [
      pkgs.${namespace}.adb-sync
      pkgs.${namespace}.adx
      android-tools
      androidStudioPackages.stable
      androidStudioPackages.beta
      androidStudioPackages.canary
      pkgs.${namespace}.diffuse-bin
    ];

    programs.java = {
      enable = true;
      package = defaultJdk;
      binfmt = false;
    };

    # Required by the binaries in the Android SDK
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        icu
        openssl
        stdenv.cc.cc
        zlib
      ];
    };

    snowfallorg.users.msfjarvis.home.config = {
      programs.gradle = {
        enable = true;
        package = pkgs.gradle-packages.mkGradle (
          (import ./gradle-version.nix)
          // {
            defaultJava = defaultJdk;
          }
        );
        settings = {
          "org.gradle.caching" = true;
          "org.gradle.parallel" = true;
          "org.gradle.workers.max" = 12;
          "org.gradle.jvmargs" = "-XX:MaxMetaspaceSize=2G -XX:+UseG1GC -Xms1G -Xmx8G";
          "org.gradle.java.home" = mapJdk defaultJdk;
          "org.gradle.java.installations.auto-detect" = false;
          "org.gradle.java.installations.auto-download" = false;
          "org.gradle.java.installations.paths" = lib.concatMapStringsSep "," mapJdk toolchains;
        };
      };
    };
  };
}
