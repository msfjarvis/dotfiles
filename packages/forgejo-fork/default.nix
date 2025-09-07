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
    (mkPatch "1176b414fe76a04c9eaa19fe355826fee87ad13e" "sha256-Xd/CFVbuiedNILyjgeT3bImm7FyDd1beA//4YApS1eQ=")
    # Render external commit links with proper prefixes
    # Disabled since it breaks tests right now.
    # (mkPatch "468d54850a29729d0f54703503fba3bd36ddb060" "sha256-uWJmHSaplFklgzN3FKKxDiuwa2/IVtvXiq/qiIkr8QY=")
  ];
}
