{
  pkgs,
  lib,
}: let
  inherit (pkgs) buildGoModule fetchFromGitea;
in
  buildGoModule rec {
    pname = "tea";
    version = "unstable-2023-12-26";

    src = fetchFromGitea {
      domain = "gitea.com";
      owner = "gitea";
      repo = "tea";
      rev = "fb4eb8be9cc2e2cd6081cb458d907742c5583c76";
      hash = "sha256-QorZO6HR+gHWHe2tMlh9UB1MShoU+JzCh73ZZ5n4IXM=";
    };

    vendorHash = "sha256-yZssgbQEuoHv5fRJCM0wsniguUxorJT0yFYUlsp+wqM=";

    ldflags = [
      "-s"
      "-w"
      "-X=main.Version=${version}"
    ];

    meta = with lib; {
      description = "A command line tool to interact with Gitea servers";
      homepage = "https://gitea.com/gitea/tea";
      license = licenses.mit;
      maintainers = with maintainers; [];
    };
  }
