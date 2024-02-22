{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.profiles.desktop;
  defaultJdk = pkgs.openjdk21;
  toolchains = [pkgs.openjdk17 defaultJdk];
in {
  options.profiles.desktop.android-dev = with lib; {
    enable = mkEnableOption "Configure a development environment for Android apps";
  };
  config = lib.mkIf cfg.android-dev.enable {
    users.users.msfjarvis.packages = with pkgs; [
      adb-sync
      adx
      androidStudioPackages.stable
      androidStudioPackages.beta
      androidStudioPackages.canary
      diffuse-bin
      kotlin
    ];

    programs.java = {
      enable = true;
      package = defaultJdk;
      binfmt = false;
    };

    home-manager.users.msfjarvis = {
      programs.gradle = {
        enable = true;
        package = pkgs.callPackage (pkgs.gradleGen
          {
            version = "8.6";
            nativeVersion = "0.22-milestone-25";
            hash = "sha256-ljHVPPPnS/pyaJOu4fiZT+5OBgxAEzWUbbohVvRA8kw=";
            defaultJava = defaultJdk;
          }) {};
        settings = {
          "org.gradle.caching" = true;
          "org.gradle.parallel" = true;
          "org.gradle.jvmargs" = "-XX:MaxMetaspaceSize=1024m -XX:+UseG1GC";
          "org.gradle.home" = defaultJdk;
          "org.gradle.java.installations.auto-detect" = false;
          "org.gradle.java.installations.auto-download" = false;
          "org.gradle.java.installations.paths" = lib.concatMapStringsSep "," (x: "${x}/lib/openjdk") toolchains;
          # Force rich console since for some reason auto detect is broken for me
          "systemProp.org.gradle.console" = "rich";
        };
      };
    };
  };
}
