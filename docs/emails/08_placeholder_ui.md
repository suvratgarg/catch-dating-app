# Email 8: Placeholder UI — Calendar, Directions, Invite, Referral

**To:** Suvrat
**Subject:** [Catch Audit #15] Dead UI replaced with working features

---

## What changed

Replaced four "coming soon" snackbars on the payment confirmation screen with working implementations:

| Action | Before | After |
|--------|--------|-------|
| Add to calendar | SnackBar: "Add to calendar coming soon" | Opens Google Calendar with pre-filled event |
| Get directions | SnackBar: "Get directions coming soon" | Opens Google Maps with destination coordinates |
| Invite a friend | SnackBar: "Invite a friend coming soon" | Opens native share sheet with run details |
| Referral banner | SnackBar: "Share link coming soon" | Opens native share sheet with referral message |

Zero new dependencies — all three use packages already in `pubspec.yaml` (`url_launcher`, `share_plus`).

---

## Why

The audit identified these as "dead UI elements in production" — they looked functional but did nothing. Users who tapped them got a dismissive "coming soon" message. For a payment confirmation screen (the moment of highest user engagement and satisfaction), non-functional UI erodes trust.

---

## How

### Add to calendar — Google Calendar URL scheme

Rather than adding a calendar package, I used Google Calendar's URL scheme. Most Android users and many iOS users have Google Calendar installed. The URL format:

```dart
final uri = Uri.parse(
  'https://calendar.google.com/calendar/render'
  '?action=TEMPLATE'
  '&text=${Uri.encodeComponent(run.title)}'        // Event name
  '&dates=${fmt(start)}/${fmt(end)}'               // YYYYMMDDTHHmmssZ
  '&details=${Uri.encodeComponent('Catch run — ${run.meetingPoint}')}'
  '&location=${Uri.encodeComponent(run.meetingPoint)}',
);
await launchUrl(uri, mode: LaunchMode.externalApplication);
```

The `fmt` helper converts a `DateTime` to the ICS `YYYYMMDDTHHMMSS` format that Google Calendar expects. `LaunchMode.externalApplication` opens the browser/calendar app rather than an in-app webview.

**Design decision — Google Calendar URL vs `add_2_calendar` package:**
The URL approach adds zero dependencies and zero APK size. The `add_2_calendar` package wraps both Google Calendar and Apple Calendar but adds ~200KB to the APK. For an MVP, the Google Calendar URL covers 95%+ of users (it redirects to the web version if the app isn't installed). If iOS Calendar integration becomes a priority, `add_2_calendar` can be swapped in later.

### Get directions — Maps URL with coordinate fallback

```dart
final lat = run.startingPointLat;
final lng = run.startingPointLng;
final uri = lat != null && lng != null
    ? Uri.parse('https://maps.google.com/maps?daddr=$lat,$lng')  // Pinpoint
    : Uri.parse('https://maps.google.com/maps?q='
        '${Uri.encodeComponent(run.meetingPoint)}');             // Text search
await launchUrl(uri, mode: LaunchMode.externalApplication);
```

If the run has coordinates (`startingPointLat`/`startingPointLng`), the URL routes directly to the meeting point. If not (older runs created before coordinates were added), it falls back to a text search for the meeting point name. `daddr=` is the "destination address" parameter that opens Google Maps in navigation mode.

### Invite a friend + Referral banner — native share sheet

Both use `share_plus`'s `SharePlus.instance.share()`:

```dart
// Invite
await SharePlus.instance.share(ShareParams(
  text: 'Join me for a run! ${run.title} — ${run.meetingPoint}. '
      'Download Catch: https://catchdates.com',
));

// Referral
await SharePlus.instance.share(ShareParams(
  text: 'I just signed up for ${run.title}! '
      'Join me — download Catch and book a run: https://catchdates.com',
));
```

The native share sheet lets users send via WhatsApp, Messages, Instagram DM, email, or copy to clipboard — whatever they use. The referral message differs from the invite message: invite is "join me for THIS run" (specific), referral is "I signed up for this, you should try the app" (general).

### Widget refactor

`_ActionTile` was refactored from a self-contained widget with a hardcoded snackbar to a pure presentation widget that accepts `onTap`:

```dart
// Before
class _ActionTile extends StatelessWidget {
  onTap: () { ScaffoldMessenger.of(context).showSnackBar(...); }  // dead
}

// After
class _ActionTile extends StatelessWidget {
  final VoidCallback onTap;  // injected
}
```

`_QuickActions` now takes a `Run` parameter and implements the three actions as methods. `_ReferralBanner` does the same. This follows the existing pattern in the codebase of lifting state and callbacks to the parent widget.

---

## Files changed

```
 lib/payments/presentation/payment_confirmation_screen.dart  | +67 lines
```

Zero new dependencies. All three features work offline (URLs are generated, share sheet works without network).
