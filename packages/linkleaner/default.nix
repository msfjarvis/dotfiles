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

  version = "2.8.0";
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
      hash = "sha256-C/vV2eTE/96KJm6Tj/onfNBnbRbq2JuSMDfaMkqfHyk=";
    };

    cargoHash = "sha256-il+L1hws2xLxoyl5ApqnqOCf2hsucpqOPv4RZB+04Ac=";

    useNextest = true;

    meta = with lib; {
      description = "A Telegram bot with an identity crisis";
      homepage = "https://msfjarvis.dev/g/linkleaner/";
      license = licenses.mit;
      platforms = platforms.all;
      mainProgram = "linkleaner";
    };
  }
