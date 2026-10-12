# USB DSD hardening: plan and implementation record

**Date:** 2026-10-12  
**Status:** User's first build/hardware pass completed; DSF compatibility and badge follow-up implemented, awaiting user retest. No agent-run builds or tests.

## Goal and reported hardware

Make Android direct-USB DSD playback dependable without changing the source
payload for volume control or weakening the working DAP path. The immediate
reference setup is Nothing Phone (1) + MOONDROP Dawn Pro (VID 12230, PID 61546).
Competing with established players means verified transport, honest diagnostics
and reproducible hardware coverage, not just a bit-perfect badge.

Reported tracks:

| Track | Report |
|---|---|
| SOUND OF DESTINY | Plays correctly; bit-perfect volume unavailable |
| Bend & Break-SACD Stereo | Plays correctly; bit-perfect volume unavailable |
| Bend And Break (DSF) | Intermittent distortion or silence; volume unavailable |

The supplied startup logs report DoP at 176,400 Hz, 24-bit / 3-byte USB
subslots, asynchronous OUT transfers, and no USB underruns. They do **not**
establish the faulty file's validity, decoder health, long-term stream stability
or byte-for-byte fidelity. The contradictory Android-managed labels coexist
with direct-USB transport state; they are not evidence that the Android mixer
actually owns this stream.

## Non-negotiable constraints

- Android only, minSdk 26; preserve the working DAP output behavior.
- No software gain, DSP, resampling or numeric float conversion on DoP/native
  DSD payloads. DAC-side volume can leave the USB payload unchanged, but must be
  discovered and verified rather than assumed from a product description.
- No implicit DSD-to-PCM conversion or full-volume fallback. PCM volume fallback
  remains an explicit opt-in and must renegotiate the complete output format.
- No unverified vendor requests or device quirks; no new dependency is planned.
- Keep changes separable. Configuration and marker checks are not independent
  proof of bit-perfect playback.
- Do not run tests, builds or hardware checks before the user's initial test
  pass. Regression tests may be added, but their results remain **not run**.

## Findings from source inspection (not hardware-confirmed causes)

1. **USB hardware volume discovery:** the Feature Unit parser uses incorrect
   UAC2 offsets/lengths, capability discovery uses UAC1 control masks, and several
   UAC2 reads use UAC1 request numbers. Volume range reads also use UAC1
   MIN/MAX/RES instead of UAC2 RANGE. Some failures disappear as “unavailable.”
2. **Volume authority:** topology discovery can select an unrelated Feature
   Unit; Android can substitute system volume for a failed direct-USB hardware
   path; the UI can persist a requested volume before hardware readback succeeds.
3. **Diagnostics:** direct DoP is assigned an Android-shared signature and the
   Flutter layer ignores the authoritative `direct_usb_active` runtime field.
   Clock verification and “verified” DoP labels can consequently overstate
   evidence. Decoder starvation is distinct from USB transfer underruns.
4. **DoP continuity:** callback and USB-ring silence generators alternate
   markers per sample rather than per multichannel frame. Their independent
   marker phases can also disagree with resumed audio. Structural auditing does
   not currently enforce complete frame/channel marker continuity.
5. **DSF boundaries:** reads are not limited to the declared audio payload,
   final channel blocks are not trimmed to valid samples, and seek bookkeeping
   reports an unrounded position while reading from an earlier block.
6. **Unsupported formats and fallback:** the DSD512 DoP carrier calculation is
   nonstandard. Direct-USB DSD initialization can fall back to an unsafe managed
   PCM sink. Native channel/rate contracts need explicit validation.
7. **USB feedback scheduling:** synchronous feedback reads and nested event
   handling can delay OUT resubmission. Endpoint type must be established from
   actual descriptors, not a Dawn Pro assumption.

DSF bit-order handling already follows the header. The vendored WavPack decoder
contract specifies that `OPEN_DSD_NATIVE` emits MSB-first bytes regardless of
the original file's qualify-mode bit-order flags; that output order is retained.
No supplied file or DAC capture yet proves the root cause of the failing
track. Older investigation notes, including
[`DSD_VOLUME_CONTROL_STATUS.md`](../DSD_VOLUME_CONTROL_STATUS.md), describe
historical observations, not verified present-day capability.

## Implementation sequence

### 1. Standards-correct controls and truthful state

- Parse bounded, version-specific AudioControl descriptors and UAC2 two-bit
  read/write capabilities; retain UAC1-specific requests for UAC1 devices.
- Discover volume on the active playback topology. Support master controls or
  complete per-channel controls; do not select a capture/unrelated unit.
- Decode bounded UAC2 RANGE subranges, signed dB/256 values and quantized
  readback. Keep software gain at unity when hardware controls the DAC.
- Expose capability/control failures and refuse system-volume substitution
  while direct USB owns playback. Reconcile UI volume only after success.
- Report actual direct-USB ownership, clock/rate verification, transport and
  decoder starvation; distinguish structural payload validation from proof.

Acceptance: DAC-side volume changes audibly in DoP while source/wire payloads
remain unchanged, or the app accurately reports why verified hardware volume
is unavailable. Native DSD is checked only where the device supports it.

### 2. DSD correctness and fail-closed output

- Enforce frame-aligned, channel-consistent DoP markers across audio, pause,
  starvation and recovery, without changing DSD data bytes.
- Bound DSF reads to the data chunk and valid samples; respect planar channel
  blocks while emitting interleaved bytes, exact byte-aligned seeks and bit order.
  Bound DFF/WavPack reads and detect corruption. Add deterministic fixtures.
- Correct standard DoP carrier calculations and reject unsupported contracts
  rather than truncating or silently selecting DSD64.
- Refuse unsafe managed fallback for direct-USB DSD. Treat source format,
  channel count, transport packing and rate as one output contract.
- Recreate the output contract for explicit PCM volume fallback.
- Replace blocking feedback reads with persistent asynchronous IN transfers on
  the same event loop; validate both interrupt and isochronous feedback devices.

Acceptance: repeated starts, seeks, pause/resume and PCM/DoP/native transitions
play the failing DSF cleanly at the correct speed, or fail with an actionable
reason before sending an unsafe stream. Working tracks and DAPs do not regress.

### 3. Evidence and compatibility coverage

- Independently generated DSF/DFF/WavPack golden payloads and wire-byte
  comparisons, not merely marker presence or DAC lock.
- Fault coverage: short reads, malformed/truncated files, starvation, failed
  control transfers, disconnect/reconnect and format changes.
- Hardware sessions: rate changes, screen-off playback and at least an hour of
  continuous playback; export requested/active format and all underrun domains.
- Publish a tested/provisional/unsupported device matrix with firmware and
  Android versions. Do not advertise competitor parity before this evidence.

## User-first testing handoff

After implementation, the user tests before the agent runs anything. Start at a
safe DAC/headphone level using hardware controls; do not assume a newly detected
control is safe at 100%. Collect full Rust/native and Flutter logs, including
initialization and the moment of distortion, rather than startup snapshots only.

Initial sequence: both working tracks, failing DSF, volume adjustment, pause/
resume, seek, track transitions, screen off, then disconnect/reconnect. Compare
against another player only after confirming it uses DoP/native DSD rather than
PCM conversion. Retain the faulty file's header/sample count and, if shareable,
a small reproducible fixture. Automated and longer hardware testing follow the
user's feedback, not before it.

## Implementation record

### Implemented in this batch (not verified by execution)

| Area | Changes | Main files |
|---|---|---|
| USB descriptors | Correct UAC2 header, terminal, Feature Unit and Clock Selector layouts; explicit UAC1 terminal/Feature Unit parsing | `rust/src/uac2/descriptors/audio_control_parser.rs` |
| DAC volume | Protocol-specific CUR/RANGE requests and capability masks; active playback topology only; writable master or complete per-channel controls; bounded, signed multi-range quantization and actual readback | `rust/src/uac2/volume_control.rs`, `rust/src/uac2/android_direct.rs` |
| Control safety | No initial volume write; grouped-channel rollback on transfer failure; generation-checked writes/snapshots; visible control errors; physical-button changes refresh actual volume instead of being classified as failed writes | `rust/src/uac2/android_direct.rs`, `rust/src/lib.rs` |
| Android/UI authority | Hardware-only requests with device identity; no Android system-volume substitution for direct USB; quantized DAC level displayed only after successful readback; native DSD and DoP remain protected even with the PCM bit-perfect preference off | `android/app/src/main/kotlin/com/mossapps/flick/MainActivity.kt`, `lib/services/uac2_service.dart`, `lib/services/player_service.dart` |
| DSF/DFF | Bounded audio chunks/sample counts, valid-tail trimming, whole-channel reads and byte-aligned seek bookkeeping; DSF block deinterleaving before output, no metadata/padding sent as audio | `rust/src/audio/dsd_engine/format/dsf_decoder.rs`, `rust/src/audio/dsd_engine/format/dff_decoder.rs` |
| WavPack DSD | Validate metadata before unsigned conversions; bound reads/seeks to declared samples; reject decoder/checksum failures and premature EOF; retain documented MSB-first native output | `rust/src/audio/dsd_engine/format/wavpack_decoder.rs` |
| DoP framing | One marker per complete multichannel frame, persistent emitted-stream phase through padding/resume, odd source-byte carry and final silence padding; stricter structural audit | `rust/src/audio/dsd_engine/dsd/dop.rs`, `rust/src/audio/engine.rs`, `rust/src/uac2/android_direct.rs` |
| Transport safety | Standard DSD512 DoP requires 1,411,200 Hz; native USB clock derives from negotiated U8/U16/U32 subslot; wire DSD requires actual clock readback and exact channels/rate; direct-USB DSD initialization cannot fall back to an Android-managed carrier | `rust/src/audio/dsd_engine/dsd/mod.rs`, `rust/src/audio/engine.rs`, `rust/src/api/audio_api.rs`, `rust/src/uac2/android_direct.rs` |
| Explicit PCM conversion | Opt-in volume conversion stops/recreates the decoder and USB transport, stages gain before playback, restores seek/pause state and fails stopped if reconfiguration is uncertain; PCM base pipeline remains DSP | `lib/services/player_service.dart`, `rust/src/audio/engine.rs` |
| Diagnostics | Actual `direct_usb_active` ownership, DSD-aware reuse signature, actual clock evidence, hardware-volume errors and generation, separate callback starvation/lock-miss counters; explicitly log `byteIdentityVerified=false` | `rust/src/audio/engine.rs`, `rust/src/api/audio_api.rs`, `rust/src/lib.rs`, `lib/services/player_service.dart` |

Regression cases have been **added, not run**: version-specific descriptors,
signed/multiple volume ranges, quantization, DSF/DFF bounds and seeks, WavPack
metadata, split DoP pairs, carrier rates, marker/channel continuity, USB-ring
padding/resume, and volume-tier protection with PCM bit-perfect disabled. USB
ring/encoder tests remain Android-gated; the protocol/arithmetic helpers and
packer fixtures do not require a DAC. No new dependency or vendor quirk was added.

### Deliberately deferred

- **Persistent asynchronous feedback IN transfers:** the existing synchronous
  feedback path remains. It can still delay OUT resubmission; this is a separate
  transfer-lifecycle change requiring real endpoint descriptors and hardware
  validation, not something this batch claims to solve.
- **Independent source-to-wire byte comparisons and reference WavPack fixtures:**
  marker checks, GET_CUR success and a DAC lock are not fidelity or audible-volume
  proof. The legacy opt-in dump is not a portable or complete DoP capture.
- **Complete format-contract/gapless redesign:** source-mode-aware direct-USB
  reuse and explicit PCM renegotiation are implemented, but all native packing
  combinations and cross-format gapless transitions need dedicated coverage.
- **Sample-accurate conversion restart:** the PCM volume fallback currently
  starts the replacement track at staged gain before restoring its seek position;
  it is not an atomic start-at-position operation.
- **Broader control topologies/vendor protocols:** ambiguous multi-input
  selectors, unsupported intermediate units or differing per-channel ranges are
  conservatively unavailable rather than guessed. The user reports working Dawn
  Pro DoP playback and volume on two tracks; broader DSD modes/topologies remain
  unverified.
- **Hardware matrix, long sessions and fault injection:** no device/firmware is
  newly certified by these changes; the supplied failing file is still needed to
  confirm its specific cause. DSF non-byte-aligned sample counts are explicitly
  refused, not silently rounded.

### Verification status and next step

The user built and tested the initial batch on Nothing Phone (1) / Dawn Pro.
**The agent has not run compilation, test suites, Flutter analysis, formatters,
app launches or hardware verification.** Knowledge-graph maintenance is separate
from app validation. Follow-up changes remain for the user's next build/test.

For the next pass, capture initialization and failure-time logs with
`direct_usb_active`/the direct path, requested/reported rate, `dsdTransport`,
`volumeMode`, `hardwareVolume`, `volumeError`, `underruns`, `dsdStarvedSamples`
and `dsdLockMisses`. Also check the unchanged DAP route before accepting the
batch; preserving its code path is not evidence of a passed regression test.

### First hardware feedback and follow-up (2026-10-12)

- **User-reported working:** SOUND OF DESTINY and Bend & Break-SACD Stereo now
  play correctly with DAC volume control. Logs identify libusb direct USB DoP,
  176,400 Hz requested/reported, no resampler and hardware volume authority.
  This confirms the reported audible behavior, not independent byte identity.
- **Remaining DSF:** Bend And Break fails rate probing at the new outer-boundary
  check. Its header/file was not supplied, so neither a stale tag pointer nor
  truncated audio is established as the cause. The decoder now measures the
  seekable extent and tolerates stale outer file-size/removed-tag bookkeeping
  only after validating the complete physical data chunk and required channel
  blocks. Overlapping metadata and genuinely truncated audio still fail; errors
  include actual/declared sizes, offsets or required/available audio bytes.
- **Missing badge:** continuous 50 ms progress ticks indefinitely reset the
  trailing 300 ms diagnostics timer. Refreshes now coalesce without resetting
  their deadline, allowing post-startup stability evidence to reach the UI.
  Both player-scene widgets subscribe to badge eligibility changes without
  rebuilding on every diagnostics update. Clock, payload, stability and
  passthrough requirements are unchanged; no badge is forced on from listening
  results, and `byteIdentityVerified=false` remains explicit.
- **Regression cases added, not run:** stale DSF outer sizes/removed-tag pointers,
  metadata overlap, missing channel blocks, physical truncation and sustained
  progress/cancelled diagnostics deadlines. Retest the failing DSF and check
  diagnostics a few seconds into the two working tracks. Startup cumulative
  `dsdStarvedSamples` is distinct from USB transfer underruns; record later values
  before treating it as continuing starvation.

### Follow-up #2: multichannel DSD sources (2026-10-12)

- **New failure after the DSF fix:** Bend And Break now parses and reaches
  `DSD wire channel mismatch: source=6, output=2` — the file is a 5.1 DSF, and
  a stereo USB DAC's wired DSD alts cannot carry six channels.
- **Policy:** with `auto`, a multichannel source on a stereo USB DAC now uses
  PCM decimation with an ITU-R BS.775-style stereo fold-down (center/surrounds
  at -3 dB, LFE excluded). Explicit `native`/`DoP` keep their mode and return
  the actionable channel error; explicit PCM works. More than six source
  channels are refused. The DAP/native-AudioTrack path is unchanged.
- **Implementation:** DSF parses `channel_type` (count fallback + warn on
  mismatch); `DsdChannelConfig` + `downmix_to_stereo` live in
  `format/mod.rs`; `PcmOutputChain` folds down only whole frames and drops
  nothing silently; the USB capability checks now require an alt whose channel
  count matches the source; source channels flow through a new
  `effective_dsd_output_mode_for_rate_and_channels` while the FRB-exported
  signatures stay unchanged.
- **Tests added, not run:** DSF `channel_type` exposure/mismatch, downmix
  coefficient checks (5.1, quad, 4ch, stereo/mono), unknown-layout refusal,
  PcmOutputChain fold-down/refusal.
- **Fold-down headroom:** the stereo mix is normalized by the sum of its
  absolute coefficients, so it is clip-safe for full-scale sources (~-4.6 dB
  for 3ch/quad, ~-7.7 dB for 5ch/5.1). The Audio Signal Path sheet now shows
  the engine's actual DSD mode ("PCM conversion" when applicable) instead of
  the preference-derived format that previously read as "Native DSD".
- **Still deferred:** DFF/WavPack explicit layout masks (count-based mapping
  only), >6-channel sources, sample-accurate start of the conversion replay,
  independent byte identity.
