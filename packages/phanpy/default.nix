{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  defaultUrl ? "https://fedi.msfjarvis.dev",
}:
buildNpmPackage {
  name = "phanpy";
  version = "2025.01.26.24f03f5-unstable-2025-03-03";

  src = fetchFromGitHub {
    owner = "cheeaun";
    repo = "phanpy";
    rev = "333142aa67d863615560e4e601eee9ed2621ee51";
    hash = "sha256-5VrQElNkeoEUrqAkuaKhkBMRHUKLKiNYTpMrlChd90w=";
  };

  npmDepsHash = "sha256-1faItl+LsUGmBmznUSog3TLRYbbCCadFzlpa30w/xOQ=";

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
