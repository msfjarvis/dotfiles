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
  systemd.network.enable = true;

  profiles.${namespace} = {
    server = {
      enable = true;
      microVM = true;
    };
  };

  # Pick up an IP from the host bridge DHCP server.
  # The host issues a static lease for this VM's MAC.
  systemd.network.networks."10-eth" = {
    matchConfig.MACAddress = lib.${namespace}.microvms.stash.mac_addr;
    networkConfig = {
      DHCP = "ipv4";
      IPv6AcceptRA = false;
    };
    dhcpV4Config = {
      ClientIdentifier = "mac";
    };
  };
  microvm.interfaces = [
    {
      type = "tap";
      id = lib.${namespace}.microvms.stash.tap_if;
      mac = lib.${namespace}.microvms.stash.mac_addr;
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

  # Integrate with systemd-machined
  microvm.registerWithMachined = true;

  # Enable SSH over VSOCK
  microvm.vsock = {
    cid = lib.${namespace}.microvms.stash.vsock;
    ssh.enable = true;
  };

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
      port = lib.${namespace}.ports.stash;
      stash = [
        {
          path = "/stash";
        }
      ];
    };
  };
  microvm.hypervisor = "qemu";
  microvm.qemu.serialConsole = true;
  services.qemuGuest.enable = true;
  system.stateVersion = "24.05";
}
