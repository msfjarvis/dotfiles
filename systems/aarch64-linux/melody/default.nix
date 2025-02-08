{
  lib,
  pkgs,
  inputs,
  namespace,
  ...
}:
{
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
    inputs.nixos-facter-modules.nixosModules.facter
    {
      facter.reportPath = ./facter.json;
      facter.detected.graphics.enable = false;
    }
  ];

  boot = {
    # Only enable for first installation
    loader.efi.canTouchEfiVariables = true;
    tmp.cleanOnBoot = true;
  };
  zramSwap.enable = true;

  topology.self.name = "oracle server";

  profiles.${namespace} = {
    server = {
      enable = true;
      tailscaleExitNode = true;
    };
  };
  networking.hostName = "melody";

  time.timeZone = "Asia/Kolkata";

  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkForce "us";
    useXkbConfig = true;
  };

  users = {
    mutableUsers = false;
    users = {
      msfjarvis = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        hashedPassword = ''$y$j9T$g8JL/B98ogQF/ryvwHpWe.$jyKMeotGz/o8Pje.nejKzPMiYOxtn//33OzMu5bAHm2'';
      };
    };
  };

  programs.command-not-found.enable = true;

  environment.systemPackages = with pkgs; [
    attic-client
    megatools
  ];

  system.stateVersion = "25.05";
}
