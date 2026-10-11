# Flick 0.22.2-beta.4

Display refresh-rate reliability: new installs follow the system rate by default, and forced modes now detect when the system rejects them.

## Display Modes

- **New installs follow the system refresh rate by default** — a fresh installation starts on the Adaptive refresh-rate mode instead of forcing the highest rate. Existing installations keep the mode they already use.
- **Forced refresh rates are verified after they are applied** — if the system ignores or downgrades the request (seen on some Fairphone 6 firmware, [#210](https://github.com/moss-apps/Flick/issues/210)), Flick returns to the system default, logs the mismatch, and stops re-forcing for the session.
- Refresh-rate requests are skipped when the target mode was already requested, instead of being re-sent from every screen mount or resume.

## Builds & Flavors

- **This GitHub download uses the `full` flavor** — it declares **All Files Access** (`MANAGE_EXTERNAL_STORAGE`) for the raw Rust filesystem scanner and complete DSD/WavPack coverage. Build: `flutter build apk --flavor full --release`.
- **Google Play uses the `play` flavor** — no All Files Access (Play policy for media apps); it scans via MediaStore/SAF plus the DSD/DSF/WavPack reconciliation path. Build: `flutter build appbundle --flavor play --release`.
- Both flavors share `applicationId` `com.mossapps.flick`, so either installs over the other.

## Getting Started

1. Refresh rate: Settings → Interface → Refresh Rate (Adaptive, 60 Hz, or maximum)
2. Bit-perfect: Settings → USB DAC (UAC2) → enable Bit-perfect output
3. Parametric EQ: Settings → Audio → Equalizer
