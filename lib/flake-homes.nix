{
  repoArgs,
  hostPkgs,
  entries,
  localModules,
  extraModules,
}:
let
  inherit (repoArgs) lib;
  inherit (repoArgs.inputs) home-manager;
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  homes = builtins.mapAttrs (
    name: entry:
    let
      parts = lib.splitString "@" name;
    in
    entry
    // {
      user = builtins.head parts;
      host = if builtins.length parts == 2 then builtins.elemAt parts 1 else null;
    }
  ) entries;

  homeLib = lib.extend (_: _: { inherit (home-manager.lib) hm; });
  homeArgs = repoArgs // {
    lib = homeLib;
  };

  # Existing home files use this option instead of setting home.username directly.
  homeUser =
    { config, pkgs, ... }@args:
    let
      cfg = config.snowfallorg.user;
      directory = if pkgs.stdenv.hostPlatform.isDarwin then "/Users" else "/home";
    in
    {
      options.snowfallorg.user = {
        enable = mkEnableOption "home user defaults";
        name = mkOption { type = types.str; };
        home.directory = mkOption {
          type = types.str;
          default = args.osConfig.users.users.${cfg.name}.home or "${directory}/${cfg.name}";
        };
      };
      config = mkIf cfg.enable {
        home.username = mkDefault cfg.name;
        home.homeDirectory = mkDefault cfg.home.directory;
      };
    };

  homeDefaults = user: {
    snowfallorg.user = {
      enable = mkDefault true;
      name = mkDefault user;
    };
  };
in
{
  standalone = builtins.mapAttrs (
    _: home:
    home-manager.lib.homeManagerConfiguration {
      pkgs = hostPkgs.${home.system};
      lib = homeLib;
      extraSpecialArgs = homeArgs // {
        inherit (home) system;
      };
      modules = [
        home.path
        homeUser
        (homeDefaults home.user)
      ]
      ++ localModules
      ++ extraModules;
    }
  ) homes;

  integrate =
    darwin:
    {
      config,
      host,
      system,
      ...
    }:
    let
      matchesByUser = lib.groupBy (home: home.user) (
        builtins.filter (home: if home.host == null then home.system == system else home.host == host) (
          builtins.attrValues homes
        )
      );
      users = config.snowfallorg.users;
    in
    {
      imports = [
        (if darwin then home-manager.darwinModules.home-manager else home-manager.nixosModules.home-manager)
      ];

      options.snowfallorg.users = mkOption {
        default = { };
        description = "Local users and their Home Manager overrides.";
        type = types.attrsOf (
          types.submodule (
            { name, ... }: {
              options = {
                create = mkOption {
                  type = types.bool;
                  default = true;
                };
                admin = mkOption {
                  type = types.bool;
                  default = true;
                };
                home = {
                  enable = mkOption {
                    type = types.bool;
                    default = true;
                  };
                  path = mkOption {
                    type = types.str;
                    default = if darwin then "/Users/${name}" else "/home/${name}";
                  };
                  # Let Home Manager merge these definitions in its own module evaluation.
                  config = mkOption {
                    type = types.deferredModule;
                    default = { };
                  };
                };
              };
            }
          )
        );
      };

      config = {
        snowfallorg.users = builtins.mapAttrs (_: _: { }) matchesByUser;
        users.users = builtins.mapAttrs (
          name: user:
          mkIf user.create (
            {
              home = mkDefault user.home.path;
            }
            // (
              if darwin then
                { isHidden = mkDefault false; }
              else
                {
                  isNormalUser = mkDefault true;
                  name = mkDefault name;
                  group = mkDefault "users";
                  extraGroups = lib.optional user.admin "wheel";
                }
            )
          )
        ) users;
        home-manager = {
          extraSpecialArgs = homeArgs // {
            inherit system;
          };
          # Keep integrated module ordering, including list options such as home.packages.
          sharedModules = lib.reverseList localModules ++ lib.reverseList extraModules ++ [ homeUser ];
          useGlobalPkgs = mkIf (matchesByUser != { }) (mkDefault true);
          users = builtins.mapAttrs (
            user: userHomes:
            mkIf users.${user}.home.enable {
              imports = [
                (homeDefaults user)
                users.${user}.home.config
              ]
              ++ builtins.map (home: home.path) userHomes;
            }
          ) matchesByUser;
        };
      };
    };
}
