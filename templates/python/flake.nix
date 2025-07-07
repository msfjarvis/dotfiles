{
  description = "devshell for a Python project";

  inputs.nixpkgs.url = "github:msfjarvis/nixpkgs/nixpkgs-unstable";

  inputs.systems.url = "github:msfjarvis/flake-systems";

  inputs.devshell.url = "github:numtide/devshell";
  inputs.devshell.inputs.nixpkgs.follows = "nixpkgs";

  inputs.flake-compat.url = "git+https://git.lix.systems/lix-project/flake-compat";
  inputs.flake-compat.flake = false;

  outputs =
    {
      systems,
      nixpkgs,
      devshell,
      ...
    }:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      devShells = eachSystem (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ devshell.overlays.default ];
          };
        in
        {
          default = pkgs.devshell.mkShell {
            bash = {
              interactive = "";
            };

            env = [
              {
                name = "DEVSHELL_NO_MOTD";
                value = 1;
              }
            ];

            packages = with pkgs; [ python312 ];
          };
        }
      );
    };
}
