{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "yarr-dev";
  version = "unstable-2024-04-05";

  src = fetchFromGitHub {
    owner = "nkanaev";
    repo = "yarr";
    rev = "5f606b1c406c6b0d25cb4a6df7955fbb0059f59d";
    hash = "sha256-1ls6rTr19QnrxsOfLc6e7Q3RNNSSaU11KyFn/6U5ZQI=";
  };

  vendorHash = null;

  ldflags = ["-s" "-w"];

  meta = with lib; {
    description = "Yet another rss reader";
    homepage = "https://github.com/nkanaev/yarr";
    license = licenses.mit;
    maintainers = with maintainers; [msfjarvis];
    mainProgram = "yarr";
  };
}
