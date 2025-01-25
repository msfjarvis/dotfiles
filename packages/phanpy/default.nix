{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  defaultUrl ? "https://fedi.msfjarvis.dev",
}:

let
  inherit (lib) optionalString;
  version = "2024.12.28.119d4b0";
in
buildNpmPackage {
  name = "phanpy";
  inherit version;

  src = fetchFromGitHub {
    owner = "cheeaun";
    repo = "phanpy";
    rev = version;
    hash = "sha256-Y1wqYaBWsiw1Ns3yhaKDd4iPEWOLVLCwJ3NCKbndS7Y=";
  };

  npmDepsHash = "sha256-hLp5CvEZmEPNuNkw2fE+sPO288S2FlsGLKKL44ux4Vk=";

  installPhase = ''
    mkdir $out
    pushd dist || exit 1
    cp -vR ./ $out/
  '';

  PHANPY_WEBSITE = optionalString (defaultUrl != null) defaultUrl;

  meta = {
    description = "A minimalistic opinionated Mastodon web client ";
    homepage = "https://github.com/cheeaun/phanpy";
    license = lib.licenses.mit;
    # Nothing to run here
    mainProgram = null;
  };
}
