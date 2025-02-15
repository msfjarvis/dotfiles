{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  defaultUrl ? "https://fedi.msfjarvis.dev",
}:
buildNpmPackage {
  name = "phanpy";
  version = "2025.01.26.24f03f5-unstable-2025-02-14";

  src = fetchFromGitHub {
    owner = "cheeaun";
    repo = "phanpy";
    rev = "6ba6602b51d081ef6ea75dee8c789a45465ce74f";
    hash = "sha256-ey6q9z17s2IQR0DWN9G8EnqyEJvNvZrgWZRxyEs4CaA=";
  };

  npmDepsHash = "sha256-pyys6/Eyl1yRlbQrbxCQG090rlu3WNd6/268f7r3kUo=";

  installPhase = ''
    mkdir $out
    pushd dist || exit 1
    cp -vR ./ $out/
  '';

  PHANPY_WEBSITE = lib.optionalString (defaultUrl != null) defaultUrl;

  meta = {
    description = "A minimalistic opinionated Mastodon web client ";
    homepage = "https://github.com/cheeaun/phanpy";
    license = lib.licenses.mit;
    # Nothing to run here
    mainProgram = null;
  };
}
