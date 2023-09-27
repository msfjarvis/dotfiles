let
  msfjarvis = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEoNv1E/D4IzNIJeJg7Rp49Jizw8aoCLSyFLcUmD1F6K";
  users = [msfjarvis];

  crusty = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIZy/fNcgmVrkzMuB/yAb6OMGnlF3BoBFzvYWZLy6OK+";
  ryzenbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM4wCylRGCmNivW6tlPn0tyNSyFN8WJa3CHFn7xsGDfV";
  wailord = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOcpYdL3Zxc0p9AOUJ15rbGqcsHPfiWaf1Ab61Cwr+NH";
  systems = [crusty ryzenbox wailord];
in {
  "secrets/wailord-tsauthkey.age".publicKeys = [wailord];
}
