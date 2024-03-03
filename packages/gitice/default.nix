{
  pkgs,
  lib,
  inputs,
}: let
  inherit (pkgs) fetchFromGitHub makeRustPlatform;
  inherit (inputs) rust-manifest;
  inherit ((import inputs.fenix {inherit pkgs;})) fromManifestFile;

  toolchain = (fromManifestFile rust-manifest).minimalToolchain;
in
  (makeRustPlatform {
    cargo = toolchain;
    rustc = toolchain;
  })
  .buildRustPackage rec {
    pname = "gitice";
    version = "2.0.4";

    src = fetchFromGitHub {
      owner = "msfjarvis";
      repo = "gitice";
      rev = "v${version}";
      hash = "sha256-GsB+2yRClow6VCPeXTdsJqXjjvIKlyg6uKK6jgVe7P8=";
    };

    cargoHash = "sha256-uAvXo/NVe+tUDV32RFPmJDaXriGiAX/jyjtgIp2PSrQ=";

    useNextest = true;

    meta = with lib; {
      description = "Snapshot your local git repositories for easy restoration";
      homepage = "https://github.com/msfjarvis/gitice";
      license = with licenses; [asl20 mit];
      maintainers = with maintainers; [msfjarvis];
      mainProgram = "gitice";
    };
  }
