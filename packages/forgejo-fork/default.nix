{
  # deadnix: skip
  lib,
  forgejo,
  fetchpatch2,
}:
let
  mkPatch =
    commitHash: hash:
    fetchpatch2 {
      url = "https://git.msfjarvis.dev/msfjarvis/forgejo/commit/${commitHash}.patch";
      inherit hash;
    };
in
forgejo.overrideAttrs {
  patches = [
    # Add `/user/repo/commit` route
    (mkPatch "6a8a1a7189e33b8799b422f5601f791ae75799ea" "sha256-Xd/CFVbuiedNILyjgeT3bImm7FyDd1beA//4YApS1eQ=")
  ];
}
