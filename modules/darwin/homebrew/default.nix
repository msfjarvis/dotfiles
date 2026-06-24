{ lib, config, ... }:
let
  inherit (lib)
    filter
    hasInfix
    map
    optionalAttrs
    ;

  primaryUser = config.system.primaryUser;
  primaryUserHome = (builtins.getAttr primaryUser config.users.users).home;
  trustDir = "${primaryUserHome}/.homebrew";
  trustPath = "${trustDir}/trust.json";

  entryName = entry: entry.name;
  isThirdPartyPackage = name: hasInfix "/" name;

  trustedTaps = map entryName config.homebrew.taps;
  trustedFormulae = filter isThirdPartyPackage (map entryName config.homebrew.brews);
  trustedCasks = filter isThirdPartyPackage (map entryName config.homebrew.casks);

  trustFile = builtins.toJSON (
    {
      trustedtaps = trustedTaps;
      trustedformulae = trustedFormulae;
    }
    // optionalAttrs (trustedCasks != [ ]) {
      trustedcasks = trustedCasks;
    }
  );
in
{
  environment.variables = {
    HOMEBREW_NO_ANALYTICS = "1";
    HOMEBREW_NO_INSECURE_REDIRECT = "1";
    HOMEBREW_NO_EMOJI = "1";
  };

  system.checks.text = lib.mkBefore ''
    mkdir -p ${trustDir}
    install -d -o ${primaryUser} -g staff -m 0755 ${trustDir}
    cat > ${trustPath} <<'EOF'
    ${trustFile}
    EOF
    chown ${primaryUser}:staff ${trustPath}
  '';

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = lib.mkDefault "uninstall";
      upgrade = true;
      extraFlags = [ "--force-cleanup" ];
    };
  };
}
