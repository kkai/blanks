# Blanks and More Blanks — submission runbook

## Current release: 5.1 (build 6), staged 2026-09-26, NOT submitted

Show all four meanings after a right answer (hold a word for the dictionary),
no repeats until the whole list is seen, missed words come back, best streak on
About, a cleaned-up word list, a privacy manifest. More Blanks adds "Review
mistakes only", Recent Words and Progress. Code: tag `v5.1-submission`.

| | Blanks | More Blanks |
|---|---|---|
| ASC app id | `286883373` | `288808376` |
| Bundle id | `com.yourcompany.Blanks` | `com.yourcompany.MoreBlanks` |
| Version 5.1 | `b0120284-42f6-49b0-a4ed-ccbc2292a05a` | `d19d651d-da71-41ed-8241-38eac9dab6eb` |
| State | `READY_FOR_REVIEW`, release **MANUAL** | same |
| Build 6 | `c93cb726-d3fa-48f8-9307-add1fcdda353`, VALID, attached | `0b9dac55-98a8-4d93-b750-2c1b5eae41bb`, VALID, attached |
| Localizations | en-US `ac26c5a0-c9f5-46d1-bb0b-b6b498f3d0ee`, de-DE `5f9872e6-ddff-4355-8588-84fb4081399a` | en-US `ff9d8a0f-271f-4f77-b0ec-94342f18d148` |
| Pending appInfo | `d734f2a6-a919-4641-ba48-7a19012e1999` | `e0182f53-60c5-435d-ae1a-92c724b09c40` |
| Review detail | `14eb0c98-dafe-4cbe-a445-3188e352a9fe` | `cf0384ad-25d9-410e-8bd8-da9a9f890404` |
| Review submission | `34d34087-6c6a-4ac5-965f-60aba4e5a4cf` (READY_FOR_REVIEW) | `8293a747-788d-4eb0-b34a-96ef654ffbd2` (READY_FOR_REVIEW) |

Read back through the API and matching the files in this folder: description,
What's New and keywords per locale; review notes (`review-notes.txt`); Blanks'
new subtitle "Learn English Words" / "Englische Vokabeln lernen" on the pending
appInfo (More Blanks keeps "Learn English Vocabulary"). More Blanks' old
description claimed "over 10.000 words, about 4 times more than Blanks"; both
apps ship the same 8,103-word list, and the new text says so.

Screenshots: `studio/appstoreconnect/screenshots/{blanks,moreblanks}-5.1/`,
three per device (game, meanings pause, About), only `APP_IPHONE_65` and
`APP_IPAD_PRO_3GEN_129` per localization, all `COMPLETE`. Blanks' stale
3.5"/4"/4.7"/5.5" sets from 2013–2018 were deleted on 5.1. More Blanks is shown
in tap mode, Blanks in drag mode, as in 5.0.

App Privacy: unchanged, **Data Not Collected**. Progress stays in the app's
Application Support folder. Age ratings: no required field null. IAPs (Blanks
tip jar coffee/bento/pizza) already approved; nothing to add.

`.ipa` checks, both passing: 5.1 (6), `ITSAppUsesNonExemptEncryption` false, no
`.storekit` or debug dylibs, `PrivacyInfo.xcprivacy` present and passing
`tools/gait/tools/verify_privacy.py`, 8,103 words in `average.plist`. `-showMeanings`
is behind `#if DEBUG` (a `strings` check cannot prove it: Swift stores short
strings inline). `-showAbout` stays in Release, as in 5.0.

### To submit

One call per app with `studio/appstoreconnect/asc.py`, or press Submit for
Review on each version in the web UI:

```
PATCH reviewSubmissions/34d34087-6c6a-4ac5-965f-60aba4e5a4cf   {"data":{"type":"reviewSubmissions","id":"…","attributes":{"submitted":true}}}
PATCH reviewSubmissions/8293a747-788d-4eb0-b34a-96ef654ffbd2   (same)
```

Release stays manual after approval.

## Build and upload

```bash
C=../../studio/appstoreconnect/credentials.txt
KID=$(sed -n 4p $C); ISS=$(sed -n 2p $C); KEY=~/.appstoreconnect/private_keys/AuthKey_$KID.p8
for S in Blanks MoreBlanks; do
  xcodebuild archive -project blanks.xcodeproj -scheme $S -configuration Release \
    -destination 'generic/platform=iOS' -archivePath build/$S.xcarchive -allowProvisioningUpdates \
    -authenticationKeyPath "$KEY" -authenticationKeyID "$KID" -authenticationKeyIssuerID "$ISS"
  xcodebuild -exportArchive -archivePath build/$S.xcarchive -exportOptionsPlist ExportOptions.plist \
    -exportPath build/export-$S -allowProvisioningUpdates \
    -authenticationKeyPath "$KEY" -authenticationKeyID "$KID" -authenticationKeyIssuerID "$ISS"
  xcrun altool --validate-app -f build/export-$S/$S.ipa -t ios --apiKey "$KID" --apiIssuer "$ISS"
  xcrun altool --upload-app   -f build/export-$S/$S.ipa -t ios --apiKey "$KID" --apiIssuer "$ISS"
done
```

`CURRENT_PROJECT_VERSION` must rise for every upload. Confirm processing with
`xcrun altool --build-status --delivery-id <uuid>`: on 2026-09-26 the API's
`builds` list did not show build 6 for ~20 minutes after the upload, while
altool already reported it VALID.

## Traps met on this round

- AppShip's `screenshots` command timed out on its first request (URLSession
  `-1001`), inside and outside the sandbox, while `asc.py`, curl and altool
  reached the API. Screenshots went up with a short `asc.py` script instead
  (delete sets, create set, reserve, PUT the upload operations, PATCH
  `uploaded` + MD5).
- Store screenshots of the meanings pause come from real play (idb driving four
  right answers), not `-showMeanings`, which shows a tick over "streak 0,
  correct 0%". Launch each app twice first so iOS drops the "◀ Other app"
  status-bar breadcrumb.
- The simulator's cached preferences survive `simctl uninstall`: More Blanks
  came up in tap mode from an earlier session's `TappingUI`.
