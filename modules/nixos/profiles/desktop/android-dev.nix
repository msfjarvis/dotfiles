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
      jarvis.adb-sync
      jarvis.adx
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
        package = pkgs.callPackage (pkgs.gradleGen
          {
            version = "8.7";
            nativeVersion = "0.22-milestone-25";
            hash = "sha256-VEw11r2Emuil7QvOo5umd9xA9J330YNVYVgtogCblh0=";
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
        };
      };
    };
  };
}
