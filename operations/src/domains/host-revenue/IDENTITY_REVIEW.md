# Private Sales migration identity review

Keep the mapped source, decisions, review output, server previews and receipts
outside Git. Start with the offline commands:

```sh
node operations/src/domains/host-revenue/migration-cli.mjs identity-template \
  /private/mapped-source.json /private/identity-decisions.json
node operations/src/domains/host-revenue/migration-cli.mjs identity-review \
  /private/mapped-source.json /private/identity-decisions.json \
  /private/identity-review.json
```

The template binds the exact source hash and contains no inferred matches.
For each source row, a reviewer adds one decision with `sourceRowId`,
`status`, and the reviewed `cohortIds` array. A `matched` decision also needs
the verified canonical `organizerId` and one or more private evidence IDs in
`evidenceRefs`. Use `unresolved` or `ambiguous` without an organizer ID when
the evidence does not establish a unique match. The output lists every source
row, including unreviewed rows. Its `mappedSource` retains original cells and
scores as historical provenance; these scores do not become current Sales
qualification scores.

Review all unmatched and ambiguous rows before freezing a new manifest from
the output's `mappedSource`. One organizer's rows are packed into one batch;
an organizer with more than 25 source rows or 120 KiB needs a separately
reviewed source partition. Reviewed cohort IDs travel with each source row,
and the import service unions them into the private Sales companion after a
fresh server preview. A current account revision change invalidates that
preview. The import does not create canonical organizers, approve contact,
publish anything or send messages.

Compensation planning uses full authoritative applied receipts and fresh
private account and related-record reads. Its output is an inspection plan,
never a rollback command. Preserve accounts with later edits, sibling imports,
activities, contacts, opportunities or other related writes; any proposed
removal requires a separately reviewed domain action with current checks.

```sh
node operations/src/domains/host-revenue/migration-cli.mjs compensation-plan \
  /private/manifest.json /private/review.json /private/full-receipts.json \
  /private/current-accounts.json /private/related-record-counts.json \
  /private/compensation-plan.json
```

The related-record counts must cover other import rows, contacts,
relationships, evidence, tasks, opportunities, stage history, commercial
records, activities and outreach proposals for each created organizer. Missing
counts keep the plan in `related_records_read_required`. The planner does not
query Firestore or execute its suggested inspection steps.
