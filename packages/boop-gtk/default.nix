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
let
  pname = "boop-gtk";
  version = "1.9.0-unstable-2024-09-29";
  description = "Port of @IvanMathy's Boop to GTK, a scriptable scratchpad for developers";
in
rustPlatform.buildRustPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "msfjarvis";
    repo = "boop-gtk";
    rev = "06f2b6743e5a380987749a59728a8d3c731d6ae4";
    hash = "sha256-ZIoEccPBXZQG8JIL0MJ5pDjfoS1hncNF8OvwS8anBxU=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-EpBnIlTvS5PTqxcEQ70hlPVvVw0E2AZg4IBgk9s53RQ=";

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
      comment = description;
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

  meta = {
    inherit description;
    homepage = "https://github.com/msfjarvis/boop-gtk";
    license = lib.licenses.mit;
    mainProgram = "boop-gtk";
    platforms = lib.platforms.linux;
  };
}
