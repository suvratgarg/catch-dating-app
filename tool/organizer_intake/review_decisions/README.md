# Organizer Review Decisions

Manual QA decisions for organizer intake entities live here until the live admin
workbench owns this state.

Use the bridge command instead of hand-writing decision files:

```sh
node tool/organizer_intake/review_decision.mjs list
node tool/organizer_intake/review_decision.mjs draft afterfly \
  --decision approve_public \
  --reviewer "admin@example.com" \
  --date 2026-06-17 \
  --note "Identity, surfaces, copy, market scope, media rights, and disabled crawl state reviewed." \
  --confirm-publication-checklist \
  --confirm-manual-reports-reviewed
node tool/organizer_intake/organizer_intake.mjs
```

Approval drafts are packet-aware: `approve_public` requires a ready
`generated/publication_review_packets.json` packet with no data or evidence
blockers. If the packet contains manual reports without artifacts, the reviewer
must pass `--confirm-manual-reports-reviewed` after treating them as prompts
rather than source evidence.

Approval publishes and indexes the website projection by default. It does not
make the organizer app-discoverable unless `--app-visibility discoverable` and
`--confirm-app-discoverability` are both set deliberately.
