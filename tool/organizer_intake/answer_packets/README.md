# Organizer Decision Answer Packets

This directory stores reviewed copies of
`generated/organizer_pending_decision_answer_packet.json`.

Create a draft with:

```sh
node tool/organizer_intake/create_decision_answer_packet.mjs \
  --date YYYY-MM-DD \
  --reviewer REVIEWER \
  --slug REVIEW_SLUG
```

Fill decisions only in the copied packet, never in `generated/`. To review the
directory-level status of copied packets, run:

```sh
node tool/organizer_intake/reviewed_decision_answer_packets.mjs --check
```

This reports whether reviewed packets are absent, incomplete, stale against the
generated source, invalid, or ready for the guarded apply step. Before applying a
specific packet, run:

```sh
node tool/organizer_intake/reviewed_decision_answer_packets.mjs \
  --packet tool/organizer_intake/answer_packets/YYYY-MM-DD-REVIEW_SLUG.json \
  --check \
  --require-ready
```

Then review the planned local commands:

```sh
node tool/organizer_intake/pending_decision_answer_plan.mjs \
  --packet tool/organizer_intake/answer_packets/YYYY-MM-DD-REVIEW_SLUG.json \
  --require-complete
```

Reviewed packets include a source fingerprint. If the generated pending-answer
packet changes after a copy is created, recreate the reviewed packet. Use the
stale-source override only after manually comparing the changed source.

Then apply through the guarded promotion pipeline:

```sh
node tool/organizer_intake/run_promotion_pipeline.mjs \
  --apply-decision-answers \
  --answer-packet tool/organizer_intake/answer_packets/YYYY-MM-DD-REVIEW_SLUG.json \
  --write-decision-answers
```

After the guarded pipeline writes the repo-backed decision JSON, move the used
packet under `answer_packets/applied/`. The active packet register scans only
top-level `*.json` files, so applied packets stay available for audit without
becoming stale blockers after the generated pending-answer source changes.
