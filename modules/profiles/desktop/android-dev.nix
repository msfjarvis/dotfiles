{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.profiles.desktop;
  defaultJdk = pkgs.temurin-bin-20;
  toolchains = [pkgs.temurin-bin-17 defaultJdk];
in {
  options.profiles.desktop.android-dev = with lib; {
    enable = mkEnableOption "Configure a development environment for Android apps";
  };
  config = lib.mkIf cfg.android-dev.enable {
    users.users.msfjarvis.packages = with pkgs; [
      androidStudioPackages.stable
      androidStudioPackages.beta
      androidStudioPackages.canary
    ];

    programs.java = {
      enable = true;
      package = defaultJdk;
      binfmt = false;
    };

    home-manager.users.msfjarvis = {
      programs.gradle = {
        enable = true;
        package = pkgs.gradle_8.override {
          java = defaultJdk;
          javaToolchains = toolchains;
        };
        settings = {
          "org.gradle.caching" = true;
          "org.gradle.parallel" = true;
          "org.gradle.jvmargs" = "-XX:MaxMetaspaceSize=1024m";
          "org.gradle.home" = defaultJdk;
          "org.gradle.java.installations.auto-detect" = false;
          "org.gradle.java.installations.auto-download" = false;
          "org.gradle.java.installations.paths" = lib.concatStringsSep "," toolchains;
        };
      };
    };
  };
}