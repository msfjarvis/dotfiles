{
  lib,
  rustPlatform,
  callPackage,
  fetchFromGitHub,
  pkg-config,
  wrapGAppsHook,
  atk,
  cairo,
  gdk-pixbuf,
  glib,
  gtk3,
  gtksourceview3,
  harfbuzz,
  pango,
  zlib,
}:
rustPlatform.buildRustPackage rec {
  pname = "boop-gtk";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "boop-gtk";
    rev = "v${version}";
    hash = "sha256-IiZ3u/rV7lCu8TbEYMJZId2qJnkMmfYFKUf/OuGCqD4=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-RVuXuNg+wlI1dS2sJ2X11fk9K1IAiVPNFHZM+/lS1+U=";

  RUSTY_V8_ARCHIVE = callPackage ./librusty_v8.nix {};

  nativeBuildInputs = [
    glib
    pkg-config
    wrapGAppsHook
  ];

  buildInputs = [atk cairo gdk-pixbuf gtk3 gtksourceview3 harfbuzz pango zlib];

  doCheck = false;

  meta = with lib; {
    description = "Port of @IvanMathy's Boop to GTK, a scriptable scratchpad for developers";
    homepage = "https://github.com/msfjarvis/boop-gtk";
    license = licenses.mit;
    maintainers = with maintainers; [msfjarvis];
    mainProgram = "boop-gtk";
    platforms = platforms.linux;
  };
}
