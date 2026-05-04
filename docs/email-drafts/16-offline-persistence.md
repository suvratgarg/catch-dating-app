# Email Draft: Enabling Firestore offline persistence explicitly

## Why

Firestore offline persistence defaults differ by platform:
- **Mobile (Android/iOS):** `persistenceEnabled: true` (default since SDK v21)
- **Web:** `persistenceEnabled: false` (default)

The app was relying on the SDK defaults. This means the web version would fail
to serve cached data when offline — every read would throw a network error.
For a social app where users browse run clubs, chats, and profiles on the go,
this is a meaningful gap.

## What changed

One line added after `Firebase.initializeApp()` in `main.dart`:

```dart
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

// Enable offline persistence explicitly — defaults differ by platform
// (mobile: enabled, web: disabled). Setting it ensures consistent behavior.
FirebaseFirestore.instance.settings =
    const Settings(persistenceEnabled: true);

await _activateFirebaseAppCheck();
```

## When this matters

- A runner checks upcoming runs while on the subway → cached data serves
- A user re-opens a chat while briefly disconnected → cached messages display
- The app is opened before Firebase Auth fully reconnects → cached profile data

## How to verify

No compilation changes needed beyond `flutter analyze`. To test: enable
airplane mode, open the app, and verify that previously loaded run clubs
and profile data still display.
