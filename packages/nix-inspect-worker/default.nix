{
  pkgs,
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "nix-inspect";
  version = "unstable-2024-04-19";

  src = fetchFromGitHub {
    owner = "bluskript";
    repo = "nix-inspect";
    rev = "86f636b1e01579b3a63b2c778c21a818b00c3d1e";
    hash = "sha256-G5Md4ghux4LBRkPE8vzLTUWxzlQ7s1xKxZ8i3ICWZU8=";
  };

  nativeBuildInputs = with pkgs; [
    meson
    ninja
    pkg-config
  ];

  buildInputs = with pkgs; [
    boost
    nlohmann_json
    nixVersions.nix_2_19.dev
  ];

  configurePhase = "pushd worker; meson setup build; popd";
  buildPhase = "pushd worker; ninja -C build; popd";

  installPhase = ''
    mkdir -p $out/bin
    cp worker/build/nix-inspect $out/bin/
  '';

  meta = with lib; {
    description = "Interactive tui for inspecting nix configs (Nix worker)";
    homepage = "https://github.com/bluskript/nix-inspect";
    changelog = "https://github.com/bluskript/nix-inspect/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ msfjarvis ];
    mainProgram = "nix-inspect";
  };
}
