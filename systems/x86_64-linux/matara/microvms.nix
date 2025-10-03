{ inputs, ... }:
{
  microvm.vms = {
    "restic-rest-server" = {
      # Host build-time reference to where the MicroVM NixOS is defined
      # under nixosConfigurations
      flake = inputs.self;
      # Specify from where to let `microvm -u` update later on
      updateFlake = "git+file:///home/msfjarvis/git-repos/dotfiles";
    };
  };

}
