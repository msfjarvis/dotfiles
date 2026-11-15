{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  gitMinimal,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "markfmt";
  version = "1.0.0";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "tnorbye";
    repo = "markfmt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yV/oHSaRJFlxHd8GLF0gnAlU/n0AWs44Pb3rZ/vIVDg=";
  };

  cargoHash = "sha256-7Un55zhN6qrRNqDo5gJpdmEZxyXH1TI4taHY7p7o9VE=";

  nativeCheckInputs = [ gitMinimal ];

  checkFlags = [
    # Relies on the network
    "--skip=install_script_verifies_checksum_and_installs_binary"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fast, standalone formatter for Markdown, Markdeep, and AI agent instruction/skill files (AGENTS.md, SKILL.md, etc)";
    homepage = "https://github.com/tnorbye/markfmt";
    changelog = "https://github.com/tnorbye/markfmt/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "markfmt";
  };
})
