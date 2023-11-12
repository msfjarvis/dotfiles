_: {
  # Workaround for https://github.com/NixOS/nixpkgs/pull/262790 accidentally flipping
  # the default. This was fixed by https://github.com/NixOS/nixpkgs/pull/266571 but
  # that hasn't made its way to nixpkgs-unstable yet.
  security.sudo.enable = true;
}
