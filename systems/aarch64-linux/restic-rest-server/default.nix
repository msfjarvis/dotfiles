{
  lib,
  inputs,
  namespace,
  ...
}:
{
  imports = [ inputs.microvm.nixosModules.microvm ];
  networking.hostName = "restic-rest-server";

  profiles.${namespace} = {
    server.enable = true;
    server.microVM = true;
  };

  microvm.hypervisor = "cloud-hypervisor";

  microvm.shares = [
    {
      source = "/nix/store";
      mountPoint = "/nix/.ro-store";
      tag = "ro-store";
      proto = "virtiofs";
    }
  ];
  services.restic.server = {
    enable = true;
    extraFlags = [ "--no-auth" ];
    listenAddress = "127.0.0.1:${toString (lib.${namespace}.ports.restic-rest-server + 1000)}";
  };
}
