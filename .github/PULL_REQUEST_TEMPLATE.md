## Summary

<!-- What changed and why. Write it like a changelog entry. Link the issue if one exists. -->

## Related issue

<!-- Closes #… or "none". -->

## Checklist

- [ ] `flutter analyze` passes
- [ ] `flutter test` passes
- [ ] Rust changes: `cargo test --manifest-path rust/Cargo.toml` passes
- [ ] Built and ran the app if the change touches a playback path (`flutter run --flavor full`)
- [ ] Generated code regenerated and committed if bridge/drift/freezed models changed
- [ ] `CHANGELOG.md` updated for user-facing changes
- [ ] No secrets, keys, tokens, or machine-local files committed
- [ ] One change per PR; no unrelated reformatting in the same diff
- [ ] Hardware tested if the Rust audio engine or USB/DAC output changed
