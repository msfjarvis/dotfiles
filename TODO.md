# Post-migration tasks for Snowfall

- [x] Replace all `host == "foo"` checks with `profiles.*` options
- [x] `nix-darwin` appears to not pull in the overlays configuration (false-positive, I was fooled by OpenJDK on Darwin being aliased to Zulu)
- [x] Restore `darwin-init` in programs.bash
- [x] Restore server-specific Starship prompt
- [ ] Re-expose packages.aarch64-darwin.macbook to let Garnix build binaries
