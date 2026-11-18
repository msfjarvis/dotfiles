{
  inputs,
  namespace,
  nixpkgsConfig,
  systems,
  homes,
  overlays,
  perSystem,
  templates,
}:
let
  inherit (inputs) nixpkgs self;
  inherit (nixpkgs) lib;

  # The public helper library is explicit so builder files under lib/ aren't exported.
  localLib = import ./default.nix;
  moduleLib = lib.extend (
    _: _: {
      ${namespace} = localLib;
      snowfall.fs.get-file = path: "${../.}/${path}";
    }
  );
  repoArgs = {
    inherit inputs namespace;
    lib = moduleLib;
  };

  readDirectory = dir: if builtins.pathExists dir then builtins.readDir dir else { };
  directories = dir: lib.filterAttrs (_: kind: kind == "directory") (readDirectory dir);

  # Use paths relative to the discovery root as keys, e.g. "profiles/server".
  discover =
    let
      scan =
        prefix: dir:
        lib.concatMapAttrs (
          name: kind:
          let
            path = dir + "/${name}";
          in
          if kind == "directory" then
            scan "${prefix}${name}/" path
          else
            lib.optionalAttrs (kind == "regular" && name == "default.nix") {
              ${lib.removeSuffix "/" prefix} = path;
            }
        ) (readDirectory dir);
    in
    scan "";

  configurations =
    dir:
    lib.concatMapAttrs (
      system: _:
      lib.concatMapAttrs (
        name: _:
        let
          path = dir + "/${system}/${name}/default.nix";
        in
        lib.optionalAttrs (builtins.pathExists path) { ${name} = { inherit system path; }; }
      ) (directories (dir + "/${system}"))
    ) (directories dir);

  packageFiles = discover ../packages;
  callEach =
    pkgs: files:
    let
      callPackage = lib.callPackageWith (pkgs // repoArgs);
    in
    inputs.flake-utils.lib.filterPackages pkgs.stdenv.hostPlatform.system (
      builtins.mapAttrs (_: path: callPackage path { }) files
    );

  packageOverlay = final: prev: {
    ${namespace} = (prev.${namespace} or { }) // callEach final packageFiles;
  };
  localOverlays = builtins.mapAttrs (_: path: import path repoArgs) (discover ../overlays);
  overlayList = builtins.attrValues localOverlays;

  hostPkgs = lib.genAttrs (import inputs.systems) (
    system:
    import nixpkgs {
      inherit system;
      config = nixpkgsConfig;
      overlays = [ packageOverlay ] ++ overlays ++ overlayList;
    }
  );

  moduleFiles = {
    nixos = discover ../modules/nixos;
    darwin = discover ../modules/darwin;
    home = discover ../modules/home;
  };
  # Export modules with the same repo helpers even when imported from another flake.
  exportModules = builtins.mapAttrs (
    _: path:
    { pkgs, ... }@args:
    let
      module = import path;
      system = pkgs.stdenv.hostPlatform.system;
      moduleArgs =
        args
        // repoArgs
        // {
          inherit system;
          pkgs = hostPkgs.${system};
        };
    in
    (if builtins.isFunction module then module moduleArgs else module) // { _file = path; }
  );

  home = import ./flake-homes.nix {
    inherit repoArgs hostPkgs;
    entries = configurations ../homes;
    localModules = builtins.attrValues moduleFiles.home;
    extraModules = homes.modules;
  };

  isDarwin = lib.hasSuffix "-darwin";
  hosts = configurations ../systems;
  buildHost =
    host:
    { system, path }:
    let
      darwin = isDarwin system;
      kind = if darwin then "darwin" else "nixos";
      pkgs = hostPkgs.${system};
      builder = if darwin then inputs.darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
    in
    builder {
      specialArgs = repoArgs // {
        inherit host system;
      };
      modules = [
        path
        ./flake-nix-options.nix
        (home.integrate darwin)
        {
          nixpkgs = {
            inherit pkgs;
            hostPlatform = lib.mkDefault system;
          };
          networking.hostName = lib.mkDefault host;
          system.configurationRevision = lib.mkIf (self ? rev) self.rev;
          nix.package = lib.mkDefault pkgs.nixVersions.latest;
          nix.extraOptions = "extra-experimental-features = nix-command flakes";
        }
      ]
      ++ builtins.attrValues moduleFiles.${kind}
      ++ (systems.hosts.${host}.modules or [ ])
      ++ systems.modules.${kind};
    };
in
inputs.flake-utils.lib.eachSystem (builtins.attrNames hostPkgs) (
  system:
  let
    pkgs = hostPkgs.${system};
  in
  perSystem pkgs
  // {
    pkgs.nixpkgs = pkgs;
    packages = pkgs.${namespace};
    checks = callEach pkgs (discover ../checks);
    devShells = callEach pkgs (discover ../shells);
  }
)
// {
  lib = localLib;
  nixosModules = exportModules moduleFiles.nixos;
  darwinModules = exportModules moduleFiles.darwin;
  homeModules = exportModules moduleFiles.home;
  nixosConfigurations = builtins.mapAttrs buildHost (
    lib.filterAttrs (_: entry: !isDarwin entry.system) hosts
  );
  darwinConfigurations = builtins.mapAttrs buildHost (
    lib.filterAttrs (_: entry: isDarwin entry.system) hosts
  );
  homeConfigurations = home.standalone;
  templates = builtins.mapAttrs (
    name: _: templates.${name} // { path = ../templates + "/${name}"; }
  ) (directories ../templates);
  overlays =
    localOverlays
    // lib.mapAttrs' (
      name: _:
      lib.nameValuePair "package/${name}" (
        _: prev: {
          ${namespace} = (prev.${namespace} or { }) // {
            ${name} = self.packages.${prev.stdenv.hostPlatform.system}.${name};
          };
        }
      )
    ) packageFiles
    // {
      default = lib.composeManyExtensions ([ packageOverlay ] ++ overlayList);
    };
}
