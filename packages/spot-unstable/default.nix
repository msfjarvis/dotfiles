{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  cargo,
  rustc,
  alsa-lib,
  appstream-glib,
  blueprint-compiler,
  desktop-file-utils,
  gettext,
  glib,
  gst_all_1,
  gtk4,
  libadwaita,
  libpulseaudio,
  libhandy,
  meson,
  ninja,
  nix-update-script,
  openssl,
  pkg-config,
  wrapGAppsHook4,
}:

stdenv.mkDerivation rec {
  pname = "spot";
  version = "0.5.0-unstable-2024-11-29";

  src = fetchFromGitHub {
    owner = "xou816";
    repo = "spot";
    rev = "e018b170c7dce3703e6d33051039e767a9b91823";
    hash = "sha256-xBgMO4whh9UP4aIBtX1Wq/6jOZMPxCZs9HcD7XAjbhQ=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-5bxfdkhDEMNgMaIPKcb2LdXpOe0bBrf/m786oortpFA=";
  };

  nativeBuildInputs = [
    cargo
    rustc
    appstream-glib
    blueprint-compiler
    desktop-file-utils
    gettext
    gtk4 # for gtk-update-icon-cache
    glib # for glib-compile-schemas
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    wrapGAppsHook4
  ];

  buildInputs = [
    alsa-lib
    glib
    gst_all_1.gst-plugins-base
    gst_all_1.gstreamer
    gtk4
    libadwaita
    libhandy
    libpulseaudio
    openssl
  ];

  # https://github.com/xou816/spot/issues/313
  mesonBuildType = "release";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Native Spotify client for the GNOME desktop";
    homepage = "https://github.com/xou816/spot";
    changelog = "https://github.com/xou816/spot/releases/tag/${src.rev}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ getchoo ];
    mainProgram = "spot";
    platforms = lib.platforms.linux;
  };
}
