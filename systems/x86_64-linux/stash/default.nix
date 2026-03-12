{
  lib,
  pkgs,
  config,
  namespace,
  ...
}:
let
  vmConfig = lib.${namespace}.microvms.${config.networking.hostName};
  inherit (lib.${namespace}) ports;
in
{
  networking.hostName = "stash";

  profiles.${namespace}.microvm-guest = {
    enable = true;
    inherit (vmConfig) mac_addr tap_if vsock;
  };

  microvm.shares = [
    {
      source = "/mediahell/MEGA/Videos";
      mountPoint = "/stash";
      tag = "stash";
      proto = "virtiofs";
    }
    {
      source = "home";
      mountPoint = "/home";
      tag = "home";
      proto = "virtiofs";
    }
  ];
  microvm.vcpu = 4;
  microvm.volumes = [
    {
      mountPoint = "/var/lib/stash";
      image = "stash.img";
      size = 1024 * 10;
    }
  ];
  # QEMU hangs when memory is exactly 2GB???
  # https://github.com/microvm-nix/microvm.nix/issues/171
  microvm.mem = 2048 + 512;

  users.users.msfjarvis.group = "users";
  users.users.msfjarvis.hashedPassword = lib.mkForce "";
  # Pin the stash service user to UID 1000 so it matches the host's msfjarvis UID.
  users.users.stash.uid = 1000;

  services.stash = {
    enable = true;
    openFirewall = true;
    pythonPackage = pkgs.python3.withPackages (p: [
      p.beautifulsoup4
      p.cloudscraper
      p.configparser
      # p.libpath
      p.lxml
      p.progressbar
      p.requests
      p.yt-dlp
      p.stashapi
    ]);
    jwtSecretKeyFile = "/home/stash-jwt";
    sessionStoreKeyFile = "/home/stash-sess";
    passwordFile = "/home/stash-pass";
    username = "msfjarvis";
    mutableSettings = true;
    settings = {
      ui.frontPageContent = [ ];
      host = "0.0.0.0";
      port = ports.stash;
      stash = [
        {
          path = "/stash";
        }
      ];
    };
  };
}
