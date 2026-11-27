{
  config,
  lib,
  namespace,
  ...
}:
let
  vm = lib.${namespace}.microvms.chrome-cdp;
in
{
  networking.hostName = "chrome-cdp";
  time.timeZone = "Asia/Kolkata";
  profiles.${namespace} = {
    microvm-guest = {
      enable = true;
      inherit (vm) mac_addr tap_if vsock;
    };
    # This guest needs neither server credentials nor access to the host's secrets.
    server.enable = lib.mkForce false;
  };
  sops.secrets = lib.mkForce { };
  services.cloudflared.certificateFile = lib.mkForce "/dev/null";
  nix.settings.netrc-file = lib.mkForce "/dev/null";

  users.users.msfjarvis = {
    isNormalUser = true;
    group = "users";
  };

  microvm.vcpu = 2;
  microvm.mem = 2560;
  microvm.volumes = [
    {
      mountPoint = "/var/lib";
      image = "chrome-cdp-data.img";
      size = 2048;
    }
  ];
  microvm.shares = lib.mkForce [
    {
      source = "/nix/store";
      mountPoint = "/nix/.ro-store";
      tag = "ro-store";
      proto = "virtiofs";
      readOnly = true;
    }
  ];
  services.openssh.openFirewall = lib.mkForce false;

  services.${namespace}.remote-chrome = {
    enable = true;
    listenAddress = vm.ipv4;
  };

  # Only the host-side reverse proxy may reach DevTools on the VM bridge.
  networking.nftables.enable = true;
  networking.firewall.extraInputRules = ''
    ip saddr 10.100.0.1 ip daddr ${vm.ipv4} tcp dport ${
      toString config.services.${namespace}.remote-chrome.port
    } accept
  '';
}
