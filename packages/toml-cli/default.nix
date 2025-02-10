{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
let
  version = "0.2.3";
in
rustPlatform.buildRustPackage {
  pname = "toml-cli";
  inherit version;

  src = fetchFromGitHub {
    owner = "gnprice";
    repo = "toml-cli";
    rev = "v${version}";
    hash = "sha256-/JDgUAjSBCPFUs8E10eD4ZQtWGgV3Bwioiy1jT91E84=";
  };

  # Do not care to make these work
  doCheck = false;

  cargoHash = "sha256-PoqVMTCRmSTt7UhCpMF3ixmAfVtpkaOfaTTmDNhrpLA=";
  useFetchCargoVendor = true;

  meta = with lib; {
    description = "Simple CLI for editing and querying TOML files.";
    homepage = "https://github.com/gnprice/toml-cli";
    changelog = "https://github.com/gnprice/toml-cli/blob/${version}/CHANGELOG.md";
    license = licenses.mit;
    mainProgram = "toml-cli";
  };
}
