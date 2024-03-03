{
  pkgs,
  lib,
}: let
  inherit (pkgs) fetchFromGitHub rustPlatform;
in
  rustPlatform.buildRustPackage rec {
    pname = "when";
    version = "0.4.0";

    src = fetchFromGitHub {
      owner = "mitsuhiko";
      repo = "when";
      rev = version;
      hash = "sha256-JvnvGD14VOXu0+xVMF4aQLvgOFLxNsebCSgKZLycHUw=";
      fetchSubmodules = true;
    };

    cargoHash = "sha256-HhxAk5pLOpn2cRDoPkrxyV27n6IGAI2vkep9j3o275I=";

    useNextest = true;

    meta = with lib; {
      description = "Timezones from the command line";
      homepage = "https://github.com/mitsuhiko/when";
      changelog = "https://github.com/mitsuhiko/when/blob/${src.rev}/CHANGELOG.md";
      license = licenses.asl20;
      maintainers = with maintainers; [msfjarvis];
      mainProgram = "when";
    };
  }
