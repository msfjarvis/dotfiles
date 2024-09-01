{ lib, ... }:
{
  # Enable SOPS, force it to be age-only
  sops.age.sshKeyPaths = lib.mkForce [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.gnupg.sshKeyPaths = lib.mkForce [ ];
}
