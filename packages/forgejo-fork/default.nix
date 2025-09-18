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
    # Also fixes a host of Markdown rendering bugs
    # https://codeberg.org/forgejo/forgejo/pulls/9146
    (fetchpatch2 {
      url = "https://codeberg.org/forgejo/forgejo/pulls/9146.patch";
      hash = "sha256-u6dvptIy0DHFsN7ARE0opMt0vYYhH+XT0YAZb6rBS1Y=";
    })
  ];
}
