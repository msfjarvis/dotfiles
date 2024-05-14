{ inputs }:
let
  inherit (inputs) deploy-rs;
in
{
  mkDeploy =
    { self }:
    let
      hosts = self.nixosConfigurations or { };
      nodes = builtins.mapAttrs (_: machine: {
        hostname = machine.config.networking.hostName;
        fastConnection = true;
        remoteBuild = false;
        autoRollback = false;
        magicRollback = false;
        profiles.system = {
          user = "root";
          sshUser = "root";
          path = deploy-rs.lib.${machine.pkgs.system}.activate.nixos machine;
        };
      }) hosts;
    in
    {
      inherit nodes;
    };
}
