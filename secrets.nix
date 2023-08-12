let
  msfjarvis = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEoNv1E/D4IzNIJeJg7Rp49Jizw8aoCLSyFLcUmD1F6K";
  users = [msfjarvis];

  crusty = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIZy/fNcgmVrkzMuB/yAb6OMGnlF3BoBFzvYWZLy6OK+";
  ryzenbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM4wCylRGCmNivW6tlPn0tyNSyFN8WJa3CHFn7xsGDfV";
  systems = [crusty ryzenbox];
in {
  "secrets/crusty-cachix-deploy.age".publicKeys = [crusty];
  "secrets/crusty-transmission-settings.age".publicKeys = [crusty];
}
