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
  version = "1.03";

  src = fetchFromGitHub {
    owner = "werman";
    repo = "noise-suppression-for-voice";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-1DgrpGYF7G5Zr9vbgtKm/Yv0HSdI7LrFYPSGKYNnNDQ=";
  };

  cmakeFlags = [
    "-DBUILD_FOR_RELEASE=ON"
    "-DBUILD_VST_PLUGIN=OFF"
    "-DBUILD_VST3_PLUGIN=OFF"
    "-DBUILD_LV2_PLUGIN=OFF"
    "-DBUILD_AU_PLUGIN=OFF"
    "-DBUILD_AUV3_PLUGIN=OFF"
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
