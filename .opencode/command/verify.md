---
description: Run the Flick verification suite (flutter analyze + flutter test + Rust tests)
---

Verify the app before declaring work done.

1. `flutter analyze` — must be clean.
2. `flutter test` — all tests must pass.
3. If Rust code changed: `cargo test --lib --manifest-path rust/Cargo.toml` — all tests must pass.
   (Integration tests in `rust/tests/` cannot link because the crate is built as
   `cdylib`/`staticlib`; only lib unit tests are runnable.)
4. If the change touches a playback path or the audio engine, note whether it
   was tested on real hardware; say so explicitly if it was not.

If anything fails, fix the root cause and re-run. Do not skip a failing suite;
report it honestly if it cannot be fixed.
