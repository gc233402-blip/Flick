# Flick 0.22.1-beta.3

Audio reliability fixes, bit-perfect/USB correctness, and player layout polish.

## Audio Reliability

- **Silent Rust-engine output is detected and recovered** — callback failures, zero-channel output, and undersized mix buffers raise an "output lost" event, and the app respawns the engine and resumes the current track instead of staying silent.
- **Repeated failures fall back to the Android player** — two engine failures within two minutes switch playback to just_audio/ExoPlayer rather than looping on the same broken output.
- **SAF/`content://` libraries play again on the standard engine** — local sources no longer carry an empty headers map into just_audio, which had routed them through its HTTP proxy and failed with "Unsupported scheme 'content'".
- **Rust and USB DAC engines stage `content://` sources correctly** — the native staging bridge rejected small byte counts, which blocked SAF files on the High Quality and bit-perfect engines.
- Managed output failures now carry burst/format details for easier triage.

## Bit-Perfect & EQ

- **Bit-perfect USB takes precedence over the parametric EQ** — PEQ no longer forces the Rust engine ahead of the bit-perfect preference, so enabling Bit-perfect is no longer silently ineffective when PEQ is active.
- PEQ is bypassed on the direct USB path, with a note in UAC2 preferences; the audio route re-resolves as soon as the Bit-perfect toggle changes.

## Player & Layout

- **Configurable artwork placement** — artwork and text offsets move independently in the player card, so album art can be nudged without shifting the title and artist.
- Playback-path errors now include the failing track.
- The floating island defaults to disabled.

## Builds & Flavors

- **This GitHub download uses the `full` flavor** — it declares **All Files Access** (`MANAGE_EXTERNAL_STORAGE`) for the raw Rust filesystem scanner and complete DSD/WavPack coverage. Build: `flutter build apk --flavor full --release`.
- **Google Play uses the `play` flavor** — no All Files Access (Play policy for media apps); it scans via MediaStore/SAF plus the DSD/DSF/WavPack reconciliation path. Build: `flutter build appbundle --flavor play --release`.
- Both flavors share `applicationId` `com.mossapps.flick`, so either installs over the other.

## Getting Started

1. Bit-perfect: Settings → USB DAC (UAC2) → enable Bit-perfect output
2. Parametric EQ: Settings → Audio → Equalizer
3. Player artwork placement: full player → layout options → artwork/text offsets
