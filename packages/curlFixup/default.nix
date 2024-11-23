{ curlMinimal }:
curlMinimal.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    ./fix-netrc-regression.patch
    ./fix-netrc-regression-2.patch
  ];
})
