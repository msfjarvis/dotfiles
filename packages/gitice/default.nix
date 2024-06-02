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
    version = "2.0.6";

    src = fetchFromGitHub {
      owner = "msfjarvis";
      repo = "gitice";
      rev = "v${version}";
      hash = "sha256-waFEeFV7R40ghUon22ATVsRn8tQrbrbIXFvz0OLPZf8=";
    };

    cargoHash = "sha256-v9l9EzGzXx6weXKF4ps4lqYCN0Ghr+fChsHAVZEK8nc=";

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
