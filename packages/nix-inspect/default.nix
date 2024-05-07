{
  pkgs,
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "nix-inspect";
  version = "unstable-2024-04-19";

  src = fetchFromGitHub {
    owner = "bluskript";
    repo = "nix-inspect";
    rev = "86f636b1e01579b3a63b2c778c21a818b00c3d1e";
    hash = "sha256-G5Md4ghux4LBRkPE8vzLTUWxzlQ7s1xKxZ8i3ICWZU8=";
  };

  WORKER_BINARY_PATH = "${lib.getExe pkgs.jarvis.nix-inspect-worker}";

  cargoHash = "sha256-go+av6Ia3/Jat4Nd9+8JkgENk2zEhmPfKjwjunBn0HU=";

  meta = with lib; {
    description = "Interactive tui for inspecting nix configs";
    homepage = "https://github.com/bluskript/nix-inspect";
    changelog = "https://github.com/bluskript/nix-inspect/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ msfjarvis ];
    mainProgram = "nix-inspect";
  };
}
