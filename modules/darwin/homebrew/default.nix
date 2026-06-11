{ lib, config, ... }:
let
  inherit (lib) filter hasInfix optionalAttrs;

  primaryUser = config.system.primaryUser;
  primaryUserHome = (builtins.getAttr primaryUser config.users.users).home;
  xdgConfigHome = config.environment.variables.XDG_CONFIG_HOME or "${primaryUserHome}/.config";
  trustDir = "${xdgConfigHome}/homebrew";
  trustPath = "${trustDir}/trust.json";

  isThirdPartyPackage = name: hasInfix "/" name;

  trustFile = builtins.toJSON (
    {
      trustedtaps = config.homebrew.taps;
      trustedformulae = filter isThirdPartyPackage config.homebrew.brews;
    }
    // optionalAttrs (config.homebrew.casks != [ ]) {
      trustedcasks = filter isThirdPartyPackage config.homebrew.casks;
    }
  );
in
{
  environment.variables = {
    HOMEBREW_NO_ANALYTICS = "1";
    HOMEBREW_NO_INSECURE_REDIRECT = "1";
    HOMEBREW_NO_EMOJI = "1";
  };

  system.activationScripts.homebrewTrustFile.text = ''
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
