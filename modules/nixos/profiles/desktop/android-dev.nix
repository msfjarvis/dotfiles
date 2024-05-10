{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profiles.desktop;
  defaultJdk = pkgs.openjdk22;
  toolchains = [
    pkgs.openjdk17
    defaultJdk
  ];
  inherit (lib) mkEnableOption mkIf;
in
{
  options.profiles.desktop.android-dev = {
    enable = mkEnableOption "Configure a development environment for Android apps";
  };
  config = mkIf cfg.android-dev.enable {
    users.users.msfjarvis.packages = with pkgs; [
      jarvis.adb-sync
      jarvis.adx
      android-tools
      androidStudioPackages.stable
      androidStudioPackages.beta
      androidStudioPackages.canary
      jarvis.diffuse-bin
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
          version = "8.8-rc-1";
          nativeVersion = "0.22-milestone-26";
          hash = "sha256-ouHP7n/97uhgFbhbLdKkNQMsQO7cAdgXIoVVbH2P6hM=";
          defaultJava = defaultJdk;
        }) { };
        settings = {
          "org.gradle.caching" = true;
          "org.gradle.parallel" = true;
          "org.gradle.jvmargs" = "-XX:MaxMetaspaceSize=1024m -XX:+UseG1GC";
          "org.gradle.home" = defaultJdk;
          "org.gradle.java.installations.auto-detect" = false;
          "org.gradle.java.installations.auto-download" = false;
          "org.gradle.java.installations.paths" = lib.concatMapStringsSep "," (
            x: "${x}/lib/openjdk"
          ) toolchains;
        };
      };
    };
  };
}
