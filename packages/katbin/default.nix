{
  fetchFromGitHub,
  rustPlatform,
  lib,
}:
let
  version = "1.3.15";
in
rustPlatform.buildRustPackage {
  pname = "katbin-cli";
  inherit version;

  src = fetchFromGitHub {
    owner = "SphericalKat";
    repo = "katbin-cli";
    rev = "v${version}";
    hash = "sha256-MGYzh5OBNPy2e+RVSppA7a1+cixyaxMwXeOuRV9aFmg=";
  };

  cargoHash = "sha256-VeXhalMQK6ULoLmzk41kXIVJccLIul6WJZ6qE8jI+ks=";
  useFetchCargoVendor = true;

  doCheck = false;

  meta = with lib; {
    description = "A CLI for katbin";
    homepage = "https://github.com/SphericalKat/katbin-cli";
    changelog = "https://github.com/SphericalKat/katbin-cli/blob/${version}/CHANGELOG.md";
    license = with licenses; [
      asl20
      mit
    ];
    mainProgram = "katbin";
  };
}
