{
  pkgs,
  lib,
  stdenv,
  pname,
  version,
  src,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit pname version src;

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
    changelog = "https://github.com/bluskript/nix-inspect/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = licenses.mit;
    mainProgram = "nix-inspect";
  };
})
