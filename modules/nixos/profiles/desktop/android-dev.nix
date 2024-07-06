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
          version = "8.9-rc-2";
          hash = "sha256-wrWKdSuCNGqJqdU4S6CILZw/DCngcAyOBQACuB1tT/k=";
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
