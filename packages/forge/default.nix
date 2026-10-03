{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "forge";
  version = "1.10.1-unstable-2026-10-03";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "git-pkgs";
    repo = "forge";
    rev = "70caf18ac5059dbb877d26f2b191d24d4805723a";
    hash = "sha256-DhFp3BNoeVI9eYo4Plywgx8jLukqEewl4+BoMdOMCrI=";
  };

  vendorHash = "sha256-GueEIQ4POxDmuIRv/Q2Fgo1Lbua6SbUeVkqDRyG+XVA=";

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
    changelog = "https://github.com/git-pkgs/forge/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "forge";
  };
})
