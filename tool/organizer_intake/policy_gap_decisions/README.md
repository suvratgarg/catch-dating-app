# Policy Gap Decisions

Reviewed product/ops decisions for organizer intake policy gaps live here.

These JSON batches annotate
`generated/organizer_policy_gap_register.json` with a review stance:
`accept`, `hold`, or `reject`. They do not enable crawls, provider lookups,
event imports, default event writes, or naming migrations by themselves.
Operational readiness still requires the approved policy to be encoded in the
repo-backed config or planner that owns that behavior.

Use the local helper instead of hand-editing JSON:

```sh
node tool/organizer_intake/policy_gap_decision.mjs list

node tool/organizer_intake/policy_gap_decision.mjs draft \
  recurring_event_crawl_policy \
  --decision hold \
  --reviewer product \
  --date 2026-06-17 \
  --note "Need monthly crawl budget before enabling scheduler." \
  --dry-run
```

For an `accept` decision, pass `--confirm-required-inputs` only after every
required input shown in the generated register has been reviewed.
