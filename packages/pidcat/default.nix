{
  fetchFromGitHub,
  installShellFiles,
  stdenvNoCC,
  lib,
}:
stdenvNoCC.mkDerivation rec {
  pname = "pidcat";
  version = "2.2.0";
  # I already fixed it in the source
  dontPatchShebangs = 1;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "pidcat";
    rev = "v${version}";
    hash = "sha256-VOIND2CzWo+LV84C+FbTC0r3FqY7VpBaWn95IKTYFT8=";
  };

  nativeBuildInputs = [installShellFiles];

  postInstall = ''
    installShellCompletion --bash bash_completion.d/pidcat
  '';

  installPhase = ''
    install -m755 -D pidcat.py $out/bin/pidcat
  '';

  meta = with lib; {
    homepage = "https://github.com/JakeWharton/pidcat";
    description = "pidcat - colored logcat script";
    license = licenses.asl20;
    platforms = platforms.all;
    maintainers = with maintainers; [msfjarvis];
    mainProgram = "pidcat";
  };
}
