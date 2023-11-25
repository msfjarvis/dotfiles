let
  # deadnix: skip
  msfjarvis = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEoNv1E/D4IzNIJeJg7Rp49Jizw8aoCLSyFLcUmD1F6K";
  # deadnix: skip
  users = [msfjarvis];

  # deadnix: skip
  crusty = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIZy/fNcgmVrkzMuB/yAb6OMGnlF3BoBFzvYWZLy6OK+";
  # deadnix: skip
  ryzenbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM4wCylRGCmNivW6tlPn0tyNSyFN8WJa3CHFn7xsGDfV";
  wailord = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMt2uQpaGrc/bnoLrMC8mVhFQ9vCbV/4QOkJZahBi95J";
  # deadnix: skip
  systems = [crusty ryzenbox wailord];
in {
  "secrets/wailord-tsauthkey.age".publicKeys = [wailord];
}
