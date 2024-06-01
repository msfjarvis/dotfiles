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
in
(makeRustPlatform {
  cargo = toolchain;
  rustc = toolchain;
}).buildRustPackage
  rec {
    pname = "gitice";
    version = "2.0.5";

    src = fetchFromGitHub {
      owner = "msfjarvis";
      repo = "gitice";
      rev = "v${version}";
      hash = "sha256-J9BWm3z6O+R8TD94/Unr+D1TGnpdpId2P0QFGtyudU8=";
    };

    cargoHash = "sha256-1s+rs6+/d1UeJkByk2Z2O1X3uzEwouAelO6GslX8exU=";

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
