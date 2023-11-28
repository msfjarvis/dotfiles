let
  msfjarvis = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEoNv1E/D4IzNIJeJg7Rp49Jizw8aoCLSyFLcUmD1F6K";
  users = [msfjarvis];

  crusty = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIZy/fNcgmVrkzMuB/yAb6OMGnlF3BoBFzvYWZLy6OK+";
  ryzenbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM4wCylRGCmNivW6tlPn0tyNSyFN8WJa3CHFn7xsGDfV";
  samosa = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAHrwuWAJ2u3OkPYqdYljPP+olbUhyklPTykKfPyyG+7";
  wailord = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMt2uQpaGrc/bnoLrMC8mVhFQ9vCbV/4QOkJZahBi95J";
  systems = [crusty ryzenbox samosa wailord];
in {
  "secrets/tsauthkey.age".publicKeys = systems ++ users;
}
