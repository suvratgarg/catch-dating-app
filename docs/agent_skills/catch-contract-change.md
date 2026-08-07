# catch-contract-change

Use for schema, Firestore rules, Functions writes, generated contracts,
repository data models, and data migration or backfill changes.

Read: `docs/data_contracts.md` and `docs/backend_operation_catalog.md`.

Optional orientation:
`node tool/agent/context_pack.mjs --task contract-change --paths contracts,functions/src,firestore.rules,lib`.

Loop: change the narrow source of truth, refresh generated contract outputs,
run data-contract checks, and document any external emulator or credential
blocker.

Failure modes to avoid: schema/model nullability drift, rules tests without
emulators, and missing backfill tooling for existing data.
