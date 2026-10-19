# Flick 0.23.0-beta.1

Localization, home widgets, and a Replay studio — plus hardened USB/DSD playback and more reliable managed audio.

## Localization & Typography

- **The app is now translatable** — a gen-l10n/ARB pipeline plus a language selector in Settings → Language. English and Simplified Chinese ship complete, and switching languages applies at runtime.
- **Localized throughout** — shared UI, player, settings, library browsing, playlists, queue, menus, manual, What's New, milestones, and Replay/Recap screens, with a Chinese layout sweep that pins dialog buttons.
- **Experimental Filipino-in-Baybayin (`tl-Tglg`)** — an opt-in pilot with 50 draft strings that only activates for an explicit script-specific locale, so existing devices are unaffected.
- **Typography** — a bundled Noto Sans SC subset keeps Chinese in a consistent typeface, and the proprietary Product Sans is replaced with the OFL-licensed Google Sans Flex.

## Mini Player & Home Widgets

- **Embedded mini player** — configurable layout and visualizer, with reset-to-defaults for both the mini player and the navigation bar.
- **Flick Replay home widget** — listening time, play count, day-over-day deltas, and top albums at a glance; four looks (Acid, Night, Signal, Album) with contrast-aware tinting. Tap to open Recap.
- Responsive widget layouts, ripple feedback, and a shared artwork sleeve deck with a bounded cache.

## Display & Visualizer

- **Adaptive refresh rate by default** for new installs; the 60 Hz option now targets a real ~60 Hz mode instead of the panel minimum.
- A single app-wide controller applies refresh-rate changes immediately, restores the saved mode after window recreation, and falls back when Android ignores a forced rate.
- **Visualizer** gains a blocks style and rainbow, monochrome, and album-art color modes.
- **Connection notices** for offline and reconnecting states, with a Settings toggle.

## Replay & Recap

- **Replay Studio** — customize recap posters with a look, background, and details; choose overview, top songs, top artists, or top album; import artwork from the camera or gallery.
- **Export posters** at 420×760 to the gallery, or export listening data as CSV, with colors sampled from artwork.
- The recap is rebuilt on composable widgets that respect reduced motion.

## USB & DSD Audio

- **Standards-correct UAC1/UAC2 AudioControl parsing** — terminals, Feature Units, and Clock Selectors; volume is discovered on the active playback topology, written with protocol-specific requests, and verified by readback.
- **Bounded DSD container decoding** and fail-closed transport; diagnostics now report the negotiated format rather than the requested preference.
- **DSD decoder respawns match the engine payload format**, fixing silent native-DSD playback after seeking or changing tracks on DAPs.
- DSD auto-mode fallback for DAPs without bit-perfect, plus corrected DoP packing, channel handling, and multichannel negotiation.

## Playback Reliability

- **Oversized managed-output bursts render in bounded chunks**, fixing silent dropouts on Bluetooth and other managed-output devices without allocating on the audio path.
- **Crossfade across mismatched sample rates**, with seek-during-crossfade targeting the incoming track; fallback state is tracked through engine switches.
- Bluetooth routing respects the selected engine preference, and Rust-only output loss no longer stalls playback.
- Managed output failures keep reporting actionable burst and format details.

## Library, Network & Artwork

- SAF songs now carry their **relative folder path**, so folder grouping and the folder tree are correct for whole-volume roots.
- **SMB IPv6 and Windows UNC URLs** parse correctly, and failed connection tests show an actionable reason such as authentication, missing share, DNS, timeout, or refusal.
- **Album artwork reset** plus stricter album identity validation; stale artwork pointers are dropped when files change.
- Recently Added and Recently Played headers are localized without losing section ordering.

## Interface & Polish

- **Unified snackbars** — one glass-themed surface with deduplication, coalescing, queueing, and motion- and accessibility-aware lifetimes.
- **App Info shows the build flavor** (`play` or `full`), and bottom sheets extend under the system navigation bar.
- Dialog cancel buttons are localized everywhere, and the support screen has an animated coffee icon.

## Builds & Flavors

- **This GitHub download uses the `full` flavor** — it declares **All Files Access** (`MANAGE_EXTERNAL_STORAGE`) for the raw Rust filesystem scanner and complete DSD/WavPack coverage. Build: `flutter build apk --flavor full --release`.
- **Google Play uses the `play` flavor** — no All Files Access (Play policy for media apps); it scans via MediaStore/SAF plus the DSD/DSF/WavPack reconciliation path. Build: `flutter build appbundle --flavor play --release`.
- Both flavors share `applicationId` `com.mossapps.flick`, so either installs over the other.

## Getting Started

1. Change language: Settings → Language
2. Mini player: Settings → Interface → Mini Player
3. Replay widget: long-press the home screen → Widgets → Flick Replay
4. Replay Studio: open Recap → customize and export a poster
