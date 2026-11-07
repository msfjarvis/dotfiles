{
  stdenvNoCC,
  fetchzip,
  lib,
}:

let
  accents = [
    "blue"
    "flamingo"
    "green"
    "lavender"
    "maroon"
    "mauve"
    "peach"
    "pink"
    "red"
    "rosewater"
    "sapphire"
    "sky"
    "teal"
    "yellow"
  ];
  themes =
    (map (accent: "catppuccin-${accent}-auto") accents)
    ++ lib.concatMap (flavor: map (accent: "catppuccin-${flavor}-${accent}") accents) [
      "frappe"
      "latte"
      "macchiato"
      "mocha"
    ];
in
stdenvNoCC.mkDerivation (finalAttrs: {
  name = "catppuccin-gitea";
  version = "1.0.2";
  src = fetchzip {
    url = "https://github.com/catppuccin/gitea/releases/download/v${finalAttrs.version}/catppuccin-gitea.tar.gz";
    hash = "sha256-rZHLORwLUfIFcB6K9yhrzr+UwdPNQVSadsw6rg8Q7gs=";
    stripRoot = false;
  };

  passthru = { inherit themes; };

  installPhase = ''
    mkdir -p $out
    cp -v ${finalAttrs.src}/*.css $out/
    diff -u \
      <(printf '%s\n' ${lib.escapeShellArgs (map (theme: "theme-${theme}.css") themes)} | sort) \
      <(cd $out && printf '%s\n' *.css | sort)
  '';
})
