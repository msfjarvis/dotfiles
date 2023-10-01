let
  msfjarvis = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEoNv1E/D4IzNIJeJg7Rp49Jizw8aoCLSyFLcUmD1F6K";
  users = [msfjarvis];

  crusty = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIZy/fNcgmVrkzMuB/yAb6OMGnlF3BoBFzvYWZLy6OK+";
  ryzenbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM4wCylRGCmNivW6tlPn0tyNSyFN8WJa3CHFn7xsGDfV";
  wailord = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID6cXnVo98T0foSYMSkco69q5KvLkQE/EQNgCUBlH39m";
  systems = [crusty ryzenbox wailord];
in {
  "secrets/wailord-tsauthkey.age".publicKeys = [wailord];
}
