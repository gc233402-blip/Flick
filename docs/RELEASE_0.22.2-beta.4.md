# Flick 0.22.2-beta.4

Display refresh-rate reliability: new installs follow the system rate by default, the 60 Hz option now targets a real ~60 Hz mode, and forced modes detect when the system rejects them.

## Display Modes

- **New installs follow the system refresh rate by default** — a fresh installation starts on the Adaptive refresh-rate mode instead of forcing the highest rate. Existing installations keep the mode they already use.
- **60 Hz now means an actual 60 Hz mode** — the Standard option picks the advertised mode closest to 60 Hz at the current resolution instead of the panel's lowest rate (10 Hz on some displays); if no ~60 Hz mode exists, Flick follows the system.
- **Refresh-rate changes apply immediately** — the selected mode is applied app-wide when it changes in Settings instead of waiting for the next screen to mount.
- **Saved refresh rate is restored on reopening**: Flick waits for saved preferences and reapplies the selected mode if Android recreated its window. A lower refresh rate while the app is in the background no longer triggers a false rejection.
- **Forced refresh rates are verified after they are applied** — if the system ignores or downgrades the request (seen on some Fairphone 6 firmware, [#210](https://github.com/moss-apps/Flick/issues/210)), Flick returns to the system default, logs the mismatch, and stops re-forcing for the session.
- Re-applying a mode already preferred by the current window is skipped.

## Builds & Flavors

- **This GitHub download uses the `full` flavor** — it declares **All Files Access** (`MANAGE_EXTERNAL_STORAGE`) for the raw Rust filesystem scanner and complete DSD/WavPack coverage. Build: `flutter build apk --flavor full --release`.
- **Google Play uses the `play` flavor** — no All Files Access (Play policy for media apps); it scans via MediaStore/SAF plus the DSD/DSF/WavPack reconciliation path. Build: `flutter build appbundle --flavor play --release`.
- Both flavors share `applicationId` `com.mossapps.flick`, so either installs over the other.

## Getting Started

1. Refresh rate: Settings → Interface → Refresh Rate (Adaptive, 60 Hz, or maximum)
2. Bit-perfect: Settings → USB DAC (UAC2) → enable Bit-perfect output
3. Parametric EQ: Settings → Audio → Equalizer
