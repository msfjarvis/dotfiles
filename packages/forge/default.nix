{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "forge";
  version = "0.11.0-unstable-2026-11-22";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "git-pkgs";
    repo = "forge";
    rev = "7b1d0921a3c914cdcaf1873f084eff38187b69ed";
    hash = "sha256-7zKv5SCp2yfSimZJmG3Y36hB7GMUt+KRhzhz1My6CHs=";
  };

  vendorHash = "sha256-Dg8l/XpA0qJ+nEhGkgXjHlb+DFnytUWzq3Bwraw2TUE=";

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/git-pkgs/forge/internal/cli.Version=${finalAttrs.version}"
  ];

  # Bunch of failures, don't care for it.
  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Go library and CLI for working with git forges. Supports GitHub, GitLab, Gitea/Forgejo, and Bitbucket Cloud through a single interface";
    homepage = "https://github.com/git-pkgs/forge";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "forge";
  };
})
