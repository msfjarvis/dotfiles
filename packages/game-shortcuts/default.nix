{
  lib,
  stdenvNoCC,
  makeDesktopItem,
  copyDesktopItems,
  # Items of format `{ name = string; id = number; }`
  games ? [ ],
}:
let
  inherit (lib) lists;
in
stdenvNoCC.mkDerivation {
  pname = "game-shortcuts";
  version = "1.0.0";

  dontUnpack = true;

  nativeBuildInputs = [ copyDesktopItems ];

  installPhase = "runHook preInstall; mkdir $out; runHook postInstall";

  desktopItems = lists.forEach games (
    game:
    (makeDesktopItem {
      name = "${game.name}";
      exec = "steam steam://rungameid/${toString game.id}";
      icon = "steam_icon_${toString game.id}";
      comment = "${game.name} on Steam";
      desktopName = "${game.name}";
      genericName = "";
      categories = [ "Game" ];
      keywords = [ ];
      terminal = false;
      type = "Application";
      mimeTypes = [ ];
    })
  );
}
