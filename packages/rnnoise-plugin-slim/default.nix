{
  lib,
  stdenv,
  cmake,
  fetchFromGitHub,
  freetype,
  gtk3-x11,
  pcre,
  pkg-config,
  xorg,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "rnnoise-plugin-slim";
  version = "1.10";

  src = fetchFromGitHub {
    owner = "werman";
    repo = "noise-suppression-for-voice";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-sfwHd5Fl2DIoGuPDjELrPp5KpApZJKzQikCJmCzhtY8=";
  };

  cmakeFlags = [
    (lib.cmakeBool "BUILD_FOR_RELEASE" true)
    (lib.cmakeBool "BUILD_VST_PLUGIN" false)
    (lib.cmakeBool "BUILD_VST3_PLUGIN" false)
    (lib.cmakeBool "BUILD_LV2_PLUGIN" false)
    (lib.cmakeBool "BUILD_AU_PLUGIN" false)
    (lib.cmakeBool "BUILD_AUV3_PLUGIN" false)
    (lib.cmakeBool "BUILD_RTCD" stdenv.isx86_64)
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    freetype
    gtk3-x11
    pcre
    xorg.libX11
    xorg.libXrandr
  ];

  meta = with lib; {
    description = "A real-time noise suppression plugin for voice based on Xiph's RNNoise";
    homepage = "https://github.com/werman/noise-suppression-for-voice";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
})
