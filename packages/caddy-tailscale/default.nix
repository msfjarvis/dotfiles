{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:
let
  version = "2.8.4";
  dist = fetchFromGitHub {
    owner = "caddyserver";
    repo = "dist";
    rev = "v${version}";
    hash = "sha256-O4s7PhSUTXoNEIi+zYASx8AgClMC5rs7se863G6w+l0=";
  };
in
buildGoModule {
  pname = "caddy-tailscale";
  version = "0-unstable-2025-02-07";

  src = fetchFromGitHub {
    owner = "tailscale";
    repo = "caddy-tailscale";
    rev = "69a970c84556728bd7e66129154864fa652fc285";
    hash = "sha256-JKjbXsEnhQqUrhr0TawdAJYMzGM5SZPs5BLE2F/1B84=";
  };

  vendorHash = "sha256-eed3AuRhRO66xFg+447xLv7otAHbzAUuhxMcNugZMOA=";

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [ "cmd/caddy" ];

  # matches upstream since v2.8.0
  tags = [ "nobadger" ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall =
    ''
      install -Dm644 ${dist}/init/caddy.service ${dist}/init/caddy-api.service -t $out/lib/systemd/system

      substituteInPlace $out/lib/systemd/system/caddy.service \
        --replace-fail "/usr/bin/caddy" "$out/bin/caddy"
      substituteInPlace $out/lib/systemd/system/caddy-api.service \
        --replace-fail "/usr/bin/caddy" "$out/bin/caddy"
    ''
    + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
      # Generating man pages and completions fail on cross-compilation
      # https://github.com/NixOS/nixpkgs/issues/308283

      $out/bin/caddy manpage --directory manpages
      installManPage manpages/*

      installShellCompletion --cmd caddy \
        --bash <($out/bin/caddy completion bash) \
        --fish <($out/bin/caddy completion fish) \
        --zsh <($out/bin/caddy completion zsh)
    '';

  meta = with lib; {
    description = "A highly experimental exploration of integrating Tailscale and Caddy";
    homepage = "https://github.com/tailscale/caddy-tailscale";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
    mainProgram = "caddy";
  };
}
