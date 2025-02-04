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
  version = "0-unstable-2024-11-05";

  src = fetchFromGitHub {
    owner = "tailscale";
    repo = "caddy-tailscale";
    rev = "f21c01b660c896bdd6bacc37178dc00d9af282b4";
    hash = "sha256-oNwnKoNZ9JhAJmtjdIS1ChbJJ1SqMy3pZu7Qj4ficE0=";
  };

  patches = [ ./update-tailscale.patch ];

  vendorHash = "sha256-Jj5Bwsr9UrowyP8mbIhUz5kGXpWTubLorZX0NUqrCh4=";

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
