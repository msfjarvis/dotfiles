_: _: prev: {
  reaction = prev.reaction.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./reaction-db-shutdown.patch ];
  });
}
