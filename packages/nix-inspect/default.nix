{
  pkgs,
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "nix-inspect";
  version = "0-unstable-2024-06-02";

  src = fetchFromGitHub {
    owner = "bluskript";
    repo = "nix-inspect";
    rev = "c55921e1d1cf980ff6351273fde6cedd5d8fa320";
    hash = "sha256-Upz+fnWJjzt5WokjO/iaiPbqiwSrqpWjrpcFOqQ4p0E=";
  };

  WORKER_BINARY_PATH = "${pkgs.callPackage ./worker.nix { inherit pname version src; }}";

  cargoHash = "sha256-ZOxvFpRrkNHGKjGMwhryNPPXP3MbLvWuc05BQTZYVvo=";

  meta = with lib; {
    description = "Interactive tui for inspecting nix configs";
    homepage = "https://github.com/bluskript/nix-inspect";
    changelog = "https://github.com/bluskript/nix-inspect/blob/${version}/CHANGELOG.md";
    license = licenses.mit;
    mainProgram = "nix-inspect";
  };
}
