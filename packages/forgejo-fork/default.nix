{
  # deadnix: skip
  lib,
  forgejo,
  fetchpatch2,
}:
forgejo.overrideAttrs {
  patches = [
    # Add `/user/repo/commit` route
    (fetchpatch2 {
      url = "https://git.msfjarvis.dev/msfjarvis/forgejo/commit/c051917a0951bb00023c536f0c2e46057026027a.patch";
      hash = "sha256-Xd/CFVbuiedNILyjgeT3bImm7FyDd1beA//4YApS1eQ=";
    })
  ];
}
