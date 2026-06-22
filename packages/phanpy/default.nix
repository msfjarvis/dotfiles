{
  jq,
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  defaultUrl ? "https://fedi.msfjarvis.dev",
}:
buildNpmPackage {
  pname = "phanpy";
  version = "2026.02.24.48b2cf7-unstable-2026-03-30";

  src = fetchFromGitHub {
    owner = "cheeaun";
    repo = "phanpy";
    rev = "ef8375d78ad11eb75e1c319ef31ae8845db240ab";
    hash = "sha256-2zrdraN1wsHNaTISuZNKTCVvU28hvQSgp71SX0ckCpM=";
  };

  npmDepsHash = "sha256-1PxjimSwP0cE8uVn7qZ3WiVwT2lAXvPd2DTEcHhfqec=";

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
  };
}
