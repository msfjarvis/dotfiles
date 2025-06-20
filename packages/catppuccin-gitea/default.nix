{
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  name = "catppuccin-gitea";
  version = "1.0.2";
  src = fetchzip {
    url = "https://github.com/catppuccin/gitea/releases/download/v${finalAttrs.version}/catppuccin-gitea.tar.gz";
    hash = "sha256-rZHLORwLUfIFcB6K9yhrzr+UwdPNQVSadsw6rg8Q7gs=";
  };

  installPhase = ''
    mkdir -p $out
    cp -v ${finalAttrs.src}/*.css $out/
  '';
})
