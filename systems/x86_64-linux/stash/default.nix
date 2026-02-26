{
  lib,
  pkgs,
  inputs,
  namespace,
  ...
}:
{
  imports = [ inputs.microvm.nixosModules.microvm ];
  networking.hostName = "stash";
  networking.useNetworkd = true;

  # Pick up an IP from the host bridge DHCP server.
  # The host issues a static lease 10.100.0.2 for MAC 02:00:00:00:00:01.
  systemd.network.networks."10-eth" = {
    matchConfig.MACAddress = "02:00:00:00:00:01";
    networkConfig = {
      DHCP = "yes";
      IPv6AcceptRA = false;
    };
  };
  microvm.interfaces = [
    {
      type = "tap";
      id = "vm-a1";
      mac = "02:00:00:00:00:01";
    }
  ];
  microvm.shares = [
    {
      source = "/nix/store";
      mountPoint = "/nix/.ro-store";
      tag = "ro-store";
      proto = "virtiofs";
    }
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
  users.users.msfjarvis.isSystemUser = true;
  users.users.msfjarvis.group = "msfjarvis";
  users.groups.msfjarvis = { };
  services.stash = {
    enable = true;
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
      host = "127.0.0.1";
      port = lib.${namespace}.ports.stash + 1000;
      stash = [
        {
          path = "/stash";
        }
      ];
    };
  };
  microvm.hypervisor = "qemu";
  system.stateVersion = "24.05";
}
