{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.profiles.desktop;
  defaultJdk = pkgs.openjdk22;
  toolchains = [
    pkgs.openjdk11
    pkgs.openjdk17
    defaultJdk
  ];
  mapOpenJdk = pkg: "${pkg}/lib/openjdk";
  inherit (lib) mkEnableOption mkIf;
in
{
  options.profiles.desktop.android-dev = {
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
      kotlin
    ];

    programs.java = {
      enable = true;
      package = defaultJdk;
      binfmt = false;
    };

    snowfallorg.users.msfjarvis.home.config = {
      programs.gradle = {
        enable = true;
        package = pkgs.callPackage (pkgs.gradleGen {
          version = "8.8-rc-2";
          nativeVersion = "0.22-milestone-26";
          hash = "sha256-tQJQcC0bI495fAd4JZ+LWHFNXRb7/sQfsZE1v4bGT+g=";
          defaultJava = defaultJdk;
        }) { };
        settings = {
          "org.gradle.caching" = true;
          "org.gradle.parallel" = true;
          "org.gradle.jvmargs" = "-XX:MaxMetaspaceSize=1024m -XX:+UseG1GC";
          "org.gradle.java.home" = mapOpenJdk defaultJdk;
          "org.gradle.java.installations.auto-detect" = false;
          "org.gradle.java.installations.auto-download" = false;
          "org.gradle.java.installations.paths" = lib.concatMapStringsSep "," mapOpenJdk toolchains;
        };
      };
    };
  };
}
