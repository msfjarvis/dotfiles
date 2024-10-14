{
  lib,
  stdenvNoCC,
  fetchzip,
  libsecret,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "rbw-pinentry-keyring";
  version = "1.12.1";

  src = fetchzip {
    url = "https://git.tozt.net/rbw/snapshot/rbw-${finalAttrs.version}.tar.gz";
    hash = "sha256-+1kalFyhk2UL+iVzuFLDsSSTudrd4QpXw+3O4J+KsLc=";
  };

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    install -Dm755 -t $out/bin bin/rbw-pinentry-keyring

    substituteInPlace $out/bin/${finalAttrs.pname} \
      --replace-fail secret-tool "${libsecret}/bin/secret-tool"
  '';

  meta = {
    description = "Unofficial command line client for Bitwarden - keyring integration";
    homepage = "https://crates.io/crates/rbw";
    changelog = "https://git.tozt.net/rbw/plain/CHANGELOG.md?id=${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "rbw-pinentry-keyring";
  };
})
