---
doc_id: schema_contracts
version: 0.1.0
updated: 2026-05-15
owner: schema_contract_unification
status: draft
---

# Schema Contracts

This directory is the new contract-first source for Firestore document shapes,
embedded profile objects, prompt catalogs, callable patch payloads, fixtures,
and future storage-path migrations.

The migration tracker lives in
`docs/schema_contract_unification_tracker.md`. Start there before changing
contract scope or generator behavior.

## Rules

- JSON Schema files use draft-07.
- Contract files describe intended persisted shape, not every legacy tolerated
  field.
- Legacy read tolerance belongs in migration notes and adapter code.
- Full Firestore documents and callable patch payloads are separate schemas.
- Firestore-specific values use `x-firestore-type` metadata. Fixture files use
  serialized timestamp objects with `_seconds` and `_nanoseconds`.
- Generated outputs must live outside `contracts/`.
- Do not hand-edit generated outputs once generator scaffolding exists.

## Current Slice

The current contract layer covers:

- private profile documents at `users/{uid}`;
- public profile projection documents at `publicProfiles/{uid}`;
- embedded profile prompt answers;
- embedded photo prompt answers;
- future embedded `ProfilePhoto` storage metadata objects;
- profile and photo prompt catalogs;
- run, run-club, relationship, social, payment, safety, operational, and demo
  Firestore document contracts;
- callable payloads for profile, run, run-club, review, safety, payment, and
  Places operations;
- direct client-write operation payloads for contextual profile decisions,
  chat messages, saved-run edges, notification read updates, and match unread
  resets;
- migration contracts for the future `profileDecisions` path and grouped
  `ProfilePhoto` storage object model;
- valid and invalid fixtures for generated schema validators.

## Known Drift Captured By This Slice

- `functions/src/profiles/updateUserProfile.ts` and `firestore.rules` now use
  the contract height range of 120 to 220 cm.
- `functions/src/profiles/updateUserProfile.ts` no longer accepts legacy
  `sexualOrientation`. The profile contract does not include it.
- `firestore.rules` no longer allows new user-profile writes with legacy
  `sexualOrientation`.
- `tool/firestore_ts_overlay.json` makes public profile `languages` optional
  while Dart has a default empty list. The contract keeps it optional because
  the backend projection currently omits empty language arrays.

## Validation

For the current no-dependency contract-source check, run:

```bash
node tool/validate_schema_contracts.mjs
```

This checks JSON syntax, schema metadata, local `$ref` targets, prompt catalog
uniqueness, catalog/schema limit alignment, and fixture placement. Full Ajv and
Dart validation are Phase 2 work.
