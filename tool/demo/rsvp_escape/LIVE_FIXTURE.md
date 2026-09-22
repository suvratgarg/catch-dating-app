# Bounded live RSVP fixture

This runner completes the five remaining fictional applications for the fixed
Saket Run Club demo form v2. Maya, Rohan and Asha are preserved. It uses ordinary
visible Chrome, the production React controls, genuine App Check, upload
finalization, consent and submit. It does not use Admin credentials, direct
Firestore writes, debug App Check tokens or modified security settings.

Dry run is the default and neither opens a browser nor writes data:

```sh
node tool/run.mjs run demo:rsvp-live-fixture
```

After inspecting the plan, apply with an explicitly labelled synthetic photo
and a single persistent receipt journal outside the repository:

```sh
node tool/demo/rsvp_escape/live_fixture.mjs --apply \
  --photo /absolute/path/to/synthetic-photo.png \
  --journal /absolute/path/to/rsvp-live-fixture-receipts.json
```

`--only priya` (or dev, kabir, leena, sara) limits a canary run. Always reuse the
same journal for this target, including after a canary: the runner skips
confirmed receipts. An exclusive journal lock prevents concurrent runs using
that journal. An attempt is recorded before any page opens, and any uncertain
attempt blocks replay until it has been reconciled in Host. Never delete a
journal to force a retry; new journals cannot detect applications from prior
runs or unrelated clients. A stale lock must be inspected before removal.

The runner fails if the organizer, form, version, active status, anonymous demo
identity policy or question keys differ. It will not relax a verified-identity
policy. It preserves existing response records and never accepts, rejects,
withdraws, admits, messages or charges applicants. Successful completion requires
both a server response ID and the rendered Application received state. The
journal contains those receipt IDs and fictional names, never session or
withdrawal tokens. Host readback and review/CRM verification remain separate.

Requires installed Google Chrome and the repository's Playwright dependency.
Headless Chromium may be denied by live attestation; use ordinary visible Chrome,
not stealth flags or debug-token substitutes. Test failures leave an uncertain
attempt instead of automatically repeating writes.

```sh
node tool/run.mjs check demo:rsvp-live-fixture
```
