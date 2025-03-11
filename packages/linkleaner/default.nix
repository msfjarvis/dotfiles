{
  pkgs,
  fetchFromGitHub,
  makeRustPlatform,
  lib,
  inputs,
}:
let
  inherit (inputs) fenix rust-manifest;
  inherit ((import fenix { inherit pkgs; })) fromManifestFile;
  toolchain = (fromManifestFile rust-manifest).minimalToolchain;

  version = "2.7.2";
in
(makeRustPlatform {
  cargo = toolchain;
  rustc = toolchain;
}).buildRustPackage
  {
    pname = "linkleaner";
    inherit version;

    src = fetchFromGitHub {
      owner = "msfjarvis";
      repo = "linkleaner";
      rev = "v${version}";
      hash = "sha256-T8m+wTiOdiBX1KFlGzSUqweEHjKLQvatGLKUiSxoZmo=";
    };

    cargoHash = "sha256-6pGOyJJUhCDPBPbuf5Fh+UsIBwejkvN1q9JGK9yPgSg=";
    useFetchCargoVendor = true;

    useNextest = true;

    meta = with lib; {
      description = "A Telegram bot with an identity crisis";
      homepage = "https://msfjarvis.dev/g/linkleaner/";
      license = licenses.mit;
      platforms = platforms.all;
      mainProgram = "linkleaner";
    };
  }
