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

  version = "0.1.1";
in
(makeRustPlatform {
  cargo = toolchain;
  rustc = toolchain;
}).buildRustPackage
  {
    pname = "adbear";
    inherit version;

    src = fetchFromGitHub {
      owner = "msfjarvis";
      repo = "adbear";
      rev = "v${version}";
      hash = "sha256-ylSR5N9l8dJGelO/+r/CpwyBAJzhVyscxv6IbkO+oow=";
    };

    cargoHash = "sha256-81kcQgApTalt2BRBf5o9emE/+52tBUZF0/dbeR2Ugzk=";
    useFetchCargoVendor = true;

    meta = {
      description = "CLI to automatically pair and join Android devices via ADB";
      homepage = "https://github.com/msfjarvis/adbear";
      license = with lib.licenses; [
        asl20
        mit
      ];
      maintainers = with lib.maintainers; [ ];
      mainProgram = "adbear";
    };
  }
