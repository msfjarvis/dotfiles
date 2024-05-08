{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
buildGoModule {
  pname = "patreon-dl";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "PrivateGER";
    repo = "patreon-dl";
    rev = "1db8b378af8c889d841036b2eaf6cb2461011ee8";
    hash = "sha256-CiMR6mb6PKj9enO4nDm959MxdQNo0UMo5nif6x37UBE=";
  };

  vendorHash = "sha256-6Y8SmgH5SFvkw3YQh8SlSktJsctped8as1FCdIc4FQc=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "A Patreon Image Downloader";
    homepage = "https://github.com/PrivateGER/patreon-dl";
    license = licenses.unlicense;
    mainProgram = "patreon-dl";
  };
}
