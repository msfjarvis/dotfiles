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

  version = "2.0.7";
in
(makeRustPlatform {
  cargo = toolchain;
  rustc = toolchain;
}).buildRustPackage
  {
    pname = "gitice";
    inherit version;

    src = fetchFromGitHub {
      owner = "msfjarvis";
      repo = "gitice";
      rev = "v${version}";
      hash = "sha256-coJSDcVEJY7FgwSlcpgoF9Hggc7v2XrET/+JXmR10l0=";
    };

    cargoHash = "sha256-YXnw1hRpUTn8tjE1bwU5AWjaRRJKI8jC/57W3U+an6A=";
    useFetchCargoVendor = true;

    useNextest = true;

    meta = with lib; {
      description = "Snapshot your local git repositories for easy restoration";
      homepage = "https://github.com/msfjarvis/gitice";
      license = with licenses; [
        asl20
        mit
      ];
      mainProgram = "gitice";
    };
  }
