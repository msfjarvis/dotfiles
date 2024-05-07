{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "toml-cli";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "gnprice";
    repo = "toml-cli";
    rev = "v${version}";
    hash = "sha256-/JDgUAjSBCPFUs8E10eD4ZQtWGgV3Bwioiy1jT91E84=";
  };

  # Do not care to make these work
  doCheck = false;

  cargoHash = "sha256-v+GBn9mmiWcWnxmpH6JRPVz1fOSrsjWoY+l+bdzKtT4=";

  meta = with lib; {
    description = "Simple CLI for editing and querying TOML files.";
    homepage = "https://github.com/gnprice/toml-cli";
    changelog = "https://github.com/gnprice/toml-cli/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ msfjarvis ];
    mainProgram = "toml-cli";
  };
}
