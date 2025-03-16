{
  lib,
  fetchzip,
  win2xcur,
  stdenvNoCC,
}:
let
  cursorMap = [
    {
      src = "Michi normal";
      dst = "left_ptr";
    }
    {
      src = "Michi help";
      dst = "question_arrow";
    }
    {
      src = "Michi work";
      dst = "left_ptr_watch";
    }
    {
      src = "Michi busy";
      dst = "watch";
    }
    {
      src = "Michi text";
      dst = "xterm";
    }
    {
      src = "Michi unavailable";
      dst = "not-allowed";
    }
    {
      src = "Michi vert";
      dst = "size_ver";
    }
    {
      src = "Michi horz";
      dst = "size_hor";
    }
    {
      src = "Michi dgn1";
      dst = "size_fdiag";
    }
    {
      src = "Michi dgn2";
      dst = "size_bdiag";
    }
    {
      src = "Michi move";
      dst = "size_all";
    }
    {
      src = "Michi link";
      dst = "link";
    }
    {
      src = "Michi precision";
      dst = "cross";
    }
    {
      src = "Michi hand";
      dst = "pointer";
    }
    {
      src = "Michi alt";
      dst = "pen";
    }
    {
      src = "Michi location";
      dst = "pin";
    }
    {
      src = "Michi person";
      dst = "center_ptr";
    }
  ];
in
stdenvNoCC.mkDerivation {
  name = "michi-cursors";
  version = "1.0.0";

  src = fetchzip {
    url = "https://til.msfjarvis.dev/Michi%20Mochievee%20Cursor.zip";
    hash = "sha256-nyJ6xb75R5QuB3SFfjkMwbb5nDOD71NhNoaj7Bv8+NA=";
  };

  buildPhase = ''
    mkdir ./output
    ${lib.getExe' win2xcur "win2xcur"} ./*.ani -s -o ./output
  '';

  installPhase =
    let
      copyCmds = lib.concatMapStringsSep "\n" (
        x: ''cp ./output/"${x.src}" $out/share/icons/michi/cursors/"${x.dst}"''
      ) cursorMap;
    in
    ''
      install -dm 755 $out/share/icons/michi/cursors
      printf "[Icon Theme]\nName=Michi Cursors\nComment=Michi Cursors\n" > $out/share/icons/michi/index.theme
    ''
    + copyCmds;
}
