{
  config,
  inputs,
  lib,
  ...
}:
let
  cfg = config.nix;
  flakes = lib.filterAttrs (_: input: input ? outputs) inputs;
in
{
  options.nix = {
    generateNixPathFromInputs = lib.mkEnableOption "generating NIX_PATH from flake inputs";
    generateRegistryFromInputs = lib.mkEnableOption "registering flake inputs in the system registry";
    linkInputs = lib.mkEnableOption "linking flake inputs under /etc/nix/inputs";
  };

  config = {
    assertions = [
      {
        assertion = !cfg.generateNixPathFromInputs || cfg.linkInputs;
        message = "nix.generateNixPathFromInputs requires nix.linkInputs";
      }
    ];
    nix.registry = builtins.mapAttrs (_: flake: { inherit flake; }) (
      if cfg.generateRegistryFromInputs then flakes else { inherit (inputs) self; }
    );
    environment.etc = lib.mkIf (cfg.linkInputs || cfg.generateRegistryFromInputs) (
      lib.mapAttrs' (
        name: input: lib.nameValuePair "nix/inputs/${name}" { source = input.outPath; }
      ) inputs
    );
    nix.nixPath = lib.mkIf cfg.generateNixPathFromInputs [ "/etc/nix/inputs" ];
  };
}
