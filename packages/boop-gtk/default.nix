{
  lib,
  rust,
  rustPlatform,
  stdenv,
  callPackage,
  copyDesktopItems,
  fetchFromGitHub,
  makeDesktopItem,
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
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "boop-gtk";
    rev = "v${version}";
    hash = "sha256-SbCe7CrVsgHqyK3d9aRyubaO9jB4KKsG1X2T0r51NzQ=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-0lt3juqiXoOSQhCY/f7Gjqt1UjUKH64Xx7PWPR7pWzk=";

  RUSTY_V8_ARCHIVE = callPackage ./librusty_v8.nix { };

  nativeBuildInputs = [
    copyDesktopItems
    glib
    pkg-config
    wrapGAppsHook
  ];

  buildInputs = [
    atk
    cairo
    gdk-pixbuf
    gtk3
    gtksourceview3
    harfbuzz
    pango
    zlib
  ];

  doCheck = false;

  desktopItems = [
    (makeDesktopItem {
      name = "fyi.zoey.Boop-GTK";
      exec = "boop-gtk";
      icon = pname;
      comment = meta.description;
      desktopName = "Boop";
      genericName = "Scriptable scratchpad";
      categories = [
        "Utility"
        "Development"
      ];
      keywords = [
        "Text"
        "Editor"
      ];
      terminal = false;
      type = "Application";
      mimeTypes = [ ];
    })
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/boop-gtk $out/bin/boop-gtk
    install -Dm644 data/fyi.zoey.Boop-GTK.png $out/share/icons/hicolor/64x64/${pname}.png
    runHook postInstall
  '';

  meta = with lib; {
    description = "Port of @IvanMathy's Boop to GTK, a scriptable scratchpad for developers";
    homepage = "https://github.com/msfjarvis/boop-gtk";
    license = licenses.mit;
    mainProgram = "boop-gtk";
    platforms = platforms.linux;
  };
}
