# https://github.com/NixOS/nixpkgs/commit/74addb0
_: final: prev: {
  actual-server =
    (prev.actual-server.override {
      nodejs_22 = prev.nodejs_24;
    }).overrideAttrs
      (
        old:
        let
          newSrc = prev.fetchzip {
            name = "actualbudget-actual-source";
            url = "https://github.com/actualbudget/actual/archive/refs/tags/v26.10.0.tar.gz";
            hash = "sha256-jBh6mrYVVX7dNz5rv/VO766ezIuwBmXbtRSKgUOkahc=";
            recursiveHash = true;
            stripRoot = true;
          };
          newTranslations = final.fetchFromGitHub {
            name = "actualbudget-translations-source";
            owner = "actualbudget";
            repo = "translations";
            rev = "1d3585a06ae3ad8b2833667234317ae149c3c008";
            hash = "sha256-e/NN5u4h5m5sO/xPLC9oO0Q5tXH+Irm3lmUheVdf+N0=";
          };
        in
        {
          version = "26.10.0";
          src = newSrc;
          srcs = [
            newSrc
            newTranslations
          ];
          translations = newTranslations;

          offlineCache = (prev.yarn-berry_4.override { nodejs = prev.nodejs_24; }).fetchYarnBerryDeps {
            src = newSrc;
            inherit (old) missingHashes;
            hash = "sha256-NYjJeQWeDsLsEme/gIkZzgwWaqpQNSfLeYgZHaPTuH8=";
          };
        }
      );
}
