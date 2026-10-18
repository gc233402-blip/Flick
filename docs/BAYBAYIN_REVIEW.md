# Baybayin pilot review

**Experimental draft: these translations are not linguistically verified.**
The app offers Tagalog written in Baybayin (`tl_Tglg`), not a language named
“Baybayin.” This first pass translates 50 messages, not the entire interface.
Everything else deliberately stays in English.

## Try it

Run `flutter run --flavor full` on Android, then open
**Settings → Interface → Language → Tagalog (Baybayin)**. The option's subtitle
warns that this is a partial draft. Language names stay recognizable, and
**English** is always written in Latin script so you can switch back.
Ordinary `tl`, `tl_PH`, `tl_Latn`, and `fil` device locales do not select Baybayin.

## Review conventions first

- This draft uses modern final-consonant spelling with **U+1714 TAGALOG SIGN
  VIRAMA** (᜔). It does not silently omit final consonants or mix in U+1715
  pamudpod (᜕). The bundled font covers both for subsequent review decisions.
- **Da/ra share ᜇ**; e/i share ᜒ and o/u share ᜓ. The draft does not use the
  separate modern ra glyph. Please decide whether to keep these conventions.
- `mga` is written ᜋᜅ; standalone `ng` is spelled for its pronunciation *nang*,
  ᜈᜅ᜔. Hyphens and ordinary punctuation are retained.
- Reviewer corrections use **kanta** for songs, **kumanta** for artist labels,
  and **Lirika** for Lyrics. Related singular/plural labels and song counts use
  these terms consistently. Next song uses **Susunod na kanta**, while Previous
  song uses **Nakaraang kanta** (including the mini-player customization label).
  These Latin wording corrections do not yet approve the Baybayin spellings.
- Please scrutinize **polder**, **Mga pagsasaayos**, and **Ihalo** as UI terms.
  These are proposed choices, not an established glossary.
  Loanword adaptation, pronunciation and brevity all need your judgment.
- Numbers, ICU placeholders and technical/product names are not transliterated.
  Song titles, artist/album names, paths, user-created playlist names and actual
  lyrics are not converted. “Album,” “Artist,” etc. below are interface labels.
- `songsCount` intentionally uses the same counted noun in both ICU branches;
  please review the rendered results for 0, 1, 2 and 101.

## How to approve or correct a row

1. Judge the **Latin Tagalog wording** against the English meaning and context.
2. Read the **Baybayin independently** and check that it says the intended
   Tagalog, including every vowel/final mark. Mechanical transcription is not
   proof of correctness.
3. Try the actual action in the app. In particular, distinguish pause/stop,
   remove/delete, and play-next/add-to-queue.
4. Edit `lib/l10n/app_tl_Tglg.arb`: update the message, its `x-latin`, and its
   `x-review-status` (`draft`, `needs-change`, or `approved`). Only the human
   reviewer should mark a row approved. Keep the corresponding row below in
   sync; automated tests check the table against the ARB, including context.
5. Run `flutter gen-l10n`, `flutter test test/l10n`, and `flutter analyze`.

All rows start as **draft**. Passing tests establishes technical integrity, not
linguistic approval. Do not call the locale verified or remove the experimental
warning until the human review and the device checklist are complete.

## Review sheet

| Key | English | Context | Latin Tagalog draft | Baybayin draft | Status |
| --- | --- | --- | --- | --- | --- |
| `addToQueue` | Add to Queue | Song action: append to the playback queue. | Idagdag sa pila | ᜁᜇᜄ᜔ᜇᜄ᜔ ᜐ ᜉᜒᜎ | draft |
| `album` | Album | Playback source label, not an album's name. | Album | ᜀᜎ᜔ᜊᜓᜋ᜔ | draft |
| `albums` | Albums | Album navigation tab and screen title. | Mga album | ᜋᜅ ᜀᜎ᜔ᜊᜓᜋ᜔ | draft |
| `allSongs` | All Songs | Playback source for the entire song library. | Lahat ng kanta | ᜎᜑᜆ᜔ ᜈᜅ᜔ ᜃᜈ᜔ᜆ | draft |
| `artist` | Artist | Playback source label, not a performer's name. Review the term for musical artists. | Kumanta | ᜃᜓᜋᜈ᜔ᜆ | draft |
| `artists` | Artists | Artist navigation tab and screen title. Review the term for musical artists. | Mga kumanta | ᜋᜅ ᜃᜓᜋᜈ᜔ᜆ | draft |
| `back` | Back | Return to the previous step or page. | Bumalik | ᜊᜓᜋᜎᜒᜃ᜔ | draft |
| `cancel` | Cancel | Cancel a dialog or action without applying it. | Kanselahin | ᜃᜈ᜔ᜐᜒᜎᜑᜒᜈ᜔ | draft |
| `close` | Close | Dismiss the current surface. | Isara | ᜁᜐᜇ | draft |
| `delete` | Delete | Destructive delete action. Check against the separate Remove action. | Burahin | ᜊᜓᜇᜑᜒᜈ᜔ | draft |
| `deselectAll` | Deselect all | Clear the selection, not the songs themselves. | Alisin lahat ng pinili | ᜀᜎᜒᜐᜒᜈ᜔ ᜎᜑᜆ᜔ ᜈᜅ᜔ ᜉᜒᜈᜒᜎᜒ | draft |
| `done` | Done | Finish the current task. | Tapos | ᜆᜉᜓᜐ᜔ | draft |
| `favorites` | Favorites | Favorites navigation tab, screen title and player action. | Mga paborito | ᜋᜅ ᜉᜊᜓᜇᜒᜆᜓ | draft |
| `folder` | Folder | Playback source label, not a directory name. Draft adapts folder to polder. | Polder | ᜉᜓᜎ᜔ᜇᜒᜇ᜔ | draft |
| `folders` | Folders | Folder navigation tab and screen title. Review the adapted loanword. | Mga polder | ᜋᜅ ᜉᜓᜎ᜔ᜇᜒᜇ᜔ | draft |
| `interfaceLabel` | Interface | Interface settings page title; contains the language selector. | Itsura | ᜁᜆ᜔ᜐᜓᜇ | draft |
| `language` | Language | Language section heading in interface settings. | Wika | ᜏᜒᜃ | draft |
| `languageSectionDescription` | Choose the language used across the app. | Language selector helper text. Review length at enlarged text sizes. | Piliin ang wikang gagamitin sa aplikasyon. | ᜉᜒᜎᜒᜁᜈ᜔ ᜀᜅ᜔ ᜏᜒᜃᜅ᜔ ᜄᜄᜋᜒᜆᜒᜈ᜔ ᜐ ᜀᜉ᜔ᜎᜒᜃᜐ᜔ᜌᜓᜈ᜔. | draft |
| `languageSystemDefault` | System default | Follow the device's language rather than an explicit app language. | Wika ng aparato | ᜏᜒᜃ ᜈᜅ᜔ ᜀᜉᜇᜆᜓ | draft |
| `lyrics` | Lyrics | Lyrics action label only; never transliterate the lyrics themselves. | Lirika | ᜎᜒᜇᜒᜃ | draft |
| `menu` | Menu | Menu navigation tab. | Talaan | ᜆᜎᜀᜈ᜔ | draft |
| `next` | Next | Advance to the next onboarding or tutorial step, not a song. | Susunod | ᜐᜓᜐᜓᜈᜓᜇ᜔ | draft |
| `nextSong` | Next song | Next-song playback control tooltip. | Susunod na kanta | ᜐᜓᜐᜓᜈᜓᜇ᜔ ᜈ ᜃᜈ᜔ᜆ | draft |
| `noSongsFound` | No Songs Found | Empty song list message. | Walang nahanap na kanta | ᜏᜎᜅ᜔ ᜈᜑᜈᜉ᜔ ᜈ ᜃᜈ᜔ᜆ | draft |
| `nowPlaying` | Now Playing | Now-playing screen heading. | Kasalukuyang tumutugtog | ᜃᜐᜎᜓᜃᜓᜌᜅ᜔ ᜆᜓᜋᜓᜆᜓᜄ᜔ᜆᜓᜄ᜔ | draft |
| `off` | Off | Disabled/off mode label, including shuffle and repeat. | Patay | ᜉᜆᜌ᜔ | draft |
| `pause` | Pause | Temporarily pause playback; distinct from Stop. | Ihinto muna | ᜁᜑᜒᜈ᜔ᜆᜓ ᜋᜓᜈ | draft |
| `play` | Play | Start or resume playback. | Patugtugin | ᜉᜆᜓᜄ᜔ᜆᜓᜄᜒᜈ᜔ | draft |
| `playNext` | Play next | Song action: insert immediately after the current song. | Isunod | ᜁᜐᜓᜈᜓᜇ᜔ | draft |
| `playlist2` | Playlist | Playback source label, not a user-created playlist name. | Talaan ng kanta | ᜆᜎᜀᜈ᜔ ᜈᜅ᜔ ᜃᜈ᜔ᜆ | draft |
| `playlists` | Playlists | Playlist navigation tab and screen title. | Mga talaan ng kanta | ᜋᜅ ᜆᜎᜀᜈ᜔ ᜈᜅ᜔ ᜃᜈ᜔ᜆ | draft |
| `previousSong` | Previous song | Previous-song playback control tooltip. | Nakaraang kanta | ᜈᜃᜇᜀᜅ᜔ ᜃᜈ᜔ᜆ | draft |
| `previousSong2` | Previous Song | Previous-song label in mini-player customization; match the playback control. | Nakaraang kanta | ᜈᜃᜇᜀᜅ᜔ ᜃᜈ᜔ᜆ | draft |
| `queue` | Queue | Playback queue title and player action label. | Pila | ᜉᜒᜎ | draft |
| `remove` | Remove | Remove from a queue/list; distinct from deleting a file. | Alisin | ᜀᜎᜒᜐᜒᜈ᜔ | draft |
| `repeat` | Repeat: {arg1} | Repeat-mode feedback. arg1 is the already-localized mode label. | Ulit: {arg1} | ᜂᜎᜒᜆ᜔: {arg1} | draft |
| `repeatMode` | Repeat Mode | Repeat-mode picker title. | Paraan ng pag-ulit | ᜉᜇᜀᜈ᜔ ᜈᜅ᜔ ᜉᜄ᜔-ᜂᜎᜒᜆ᜔ | draft |
| `search` | Search | Search navigation tab and action. | Hanapin | ᜑᜈᜉᜒᜈ᜔ | draft |
| `selectAll` | Select All | Select every item without modifying its metadata. | Piliin lahat | ᜉᜒᜎᜒᜁᜈ᜔ ᜎᜑᜆ᜔ | draft |
| `settings` | Settings | Settings navigation tab and screen title. Review this terminology. | Mga pagsasaayos | ᜋᜅ ᜉᜄ᜔ᜐᜐᜀᜌᜓᜐ᜔ | draft |
| `share` | Share | Share action. | Ibahagi | ᜁᜊᜑᜄᜒ | draft |
| `shuffle` | Shuffle | Shuffle-play action. | Ihalo | ᜁᜑᜎᜓ | draft |
| `shuffle2` | Shuffle: {arg1} | Shuffle-mode feedback. arg1 is the already-localized mode label. | Paghalo: {arg1} | ᜉᜄ᜔ᜑᜎᜓ: {arg1} | draft |
| `shuffleMode` | Shuffle Mode | Shuffle-mode picker title. | Paraan ng paghalo | ᜉᜇᜀᜈ᜔ ᜈᜅ᜔ ᜉᜄ᜔ᜑᜎᜓ | draft |
| `songs` | {arg1} • {arg2} songs | Album detail subtitle: arg1 is duration, arg2 is song count. Do not change either placeholder. | {arg1} • {arg2} kanta | {arg1} • {arg2} ᜃᜈ᜔ᜆ | draft |
| `songs14` | Songs | Songs navigation tab and screen title. | Mga kanta | ᜋᜅ ᜃᜈ᜔ᜆ | draft |
| `songsCount` | {count, plural, =1{{count} song} other{{count} songs}} | Recap song count. Tagalog counted nouns do not take English's plural suffix; both ICU branches intentionally use kanta. | {count, plural, =1{{count} kanta} other{{count} kanta}} | {count, plural, =1{{count} ᜃᜈ᜔ᜆ} other{{count} ᜃᜈ᜔ᜆ}} | draft |
| `stop` | Stop | Stop an operation, such as library scanning; distinct from Pause. | Ihinto | ᜁᜑᜒᜈ᜔ᜆᜓ | draft |
| `tracks` | {_totalTracks} tracks | Album track count. Keep the underscore-prefixed placeholder unchanged. | {_totalTracks} kanta | {_totalTracks} ᜃᜈ᜔ᜆ | draft |
| `volume` | Volume | Playback volume label and player action. | Lakas ng tunog | ᜎᜃᜐ᜔ ᜈᜅ᜔ ᜆᜓᜈᜓᜄ᜔ | draft |

## Rendering and device checklist

The host tests load the actual bundled fonts and exercise the selector,
navigation and mini-player at narrow widths and enlarged text sizes. Optional
review images (not pixel-golden assertions):

```sh
flutter test test/l10n/baybayin_layout_test.dart --dart-define=BAYBAYIN_SCREENSHOTS=true
```

Images go to `build/baybayin_shots/`. If your Markdown reader shows boxes in
the table, use those images or the Android app; a document viewer does not
automatically load the app's bundled font.

Still check manually on **Android 8/API 26 and a current Android version**:

- [ ] English → Baybayin → Chinese → English updates the visible UI.
- [ ] Force-stop/relaunch retains Baybayin, and choosing System default restores
      device-following behavior. Filipino/Tagalog system settings stay in English
      unless the user explicitly chooses the Baybayin script.
- [ ] Kudlit and virama sit correctly, including in bold; no boxes, detached
      marks or clipped ascenders/descenders. Review both short and long labels.
- [ ] At the largest system font size, scroll the language card and activate the
      always-Latin **English** option. Also check nav labels and player tooltips.
- [ ] Actual song/artist/album/playlist names and lyrics remain unchanged.
- [ ] Flutter's built-in dialogs/date pickers/text-selection controls load
      successfully. **Their stock Tagalog labels are Latin-script Tagalog, not
      Baybayin**; they are outside this 50-message pilot.
- [ ] Android notifications, lock screen and home widgets: verify separately.
      Native resource translations were not added, native views do not inherit
      the Flutter font, and service-created app labels may follow the app locale.
      Do not infer native rendering support from the Flutter tests.
- [ ] TalkBack: check focus, announcements and language switching. Baybayin
      pronunciation is **not guaranteed** by installed Tagalog TTS. Use English
      if the screen reader cannot read this experimental script reliably.

## Implementation notes

- `app_tl.arb` is intentionally empty, required by Flutter's script-variant
  generator. It is not offered as a separate app language; the generated base
  supplies English fallback messages. Do not fill it with copied English text.
- `kSupportedLocales` and `resolveAppLocale` control the actual app options;
  the generated list additionally includes the internal `tl` base.
- Use `kAppLocalizationsDelegates` and `lookupFlickLocalizations` for the app,
  not the raw generated lookup/delegate. The pilot deliberately uses English
  ICU formatting rules (`localeName == 'en'`) for both inherited and translated
  app messages, so untranslated plurals retain English grammar. The UI locale
  remains `tl_Tglg`; Flutter's stock controls still resolve Tagalog normally.
  Revisit the per-message formatting policy before expanding beyond the pilot.
- The full, unmodified **Noto Sans Tagalog Regular** adds 53,012 bytes, is bundled
  offline, declared as a theme fallback, and credited in the app's Licenses page.
  No app dependency or audio-engine change is needed.
- Font source: [Google Fonts, ofl/notosanstagalog](https://github.com/google/fonts/tree/main/ofl/notosanstagalog),
  Git blob `ca69d2626661d2baf304e591bad6914574314aef`.
  SHA-256: `871a66319d10d1a027eee889f75ea49be0b7d2a4e97acd6bf7f7a0ed1d741aac`.
  The matching SIL OFL 1.1 notice is `assets/fonts/NotoSansTagalog-OFL.txt`.
