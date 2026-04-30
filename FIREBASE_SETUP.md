# Firebase Setup

This file is now a compatibility pointer. The detailed Firebase setup content
was consolidated so there is one clear source of truth.

Use these current docs instead:

- [`firebase/README.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/firebase/README.md) for day-to-day environment switching, Flutter wrapper commands, and refresh steps.
- [`codex_audit/firebase_environment_current_state.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/codex_audit/firebase_environment_current_state.md) for the verified Firebase/App Check/Functions state.
- [`functions/README.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/functions/README.md) for callable App Check defaults, public HTTP endpoint notes, Razorpay secrets, and deploy commands.

Current status as of 2026-04-30:

- `dev`, `staging`, and `prod` Firebase projects are configured.
- Android, iOS/macOS, and web app registrations exist for all three projects.
- App Check providers are registered for Android, iOS/macOS, and web.
- Firestore, Storage, Auth, and callable Functions enforce App Check.
- The old prod `com.example.*` and Windows web Firebase app registrations were removed and are pending Firebase's normal 30-day permanent deletion window.
- Dev and staging Functions currently reuse the prod Razorpay test-mode secrets. Replace this with environment-owned Razorpay credentials before live payments.

Do not add new Firebase setup details here. Update the current docs above
instead.
