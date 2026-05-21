---
doc_id: schema_contracts
version: 0.1.1
updated: 2026-05-22
owner: data_contracts
status: draft
---

# Schema Contracts

This directory is the new contract-first source for Firestore document shapes,
embedded profile objects, prompt catalogs, callable patch payloads, fixtures,
and future storage-path migrations.

The contract runbook lives in `docs/data_contracts.md`. Start there before
changing contract scope, generator behavior, rules metadata, or migration
policy.

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
- event, event-success, club, relationship, social, payment, safety,
  operational, and demo Firestore document contracts;
- callable request payloads for profile, event, club, review, safety, payment,
  and Places operations;
- selected callable response payloads that the Flutter app decodes into typed
  client response objects;
- direct client-write operation payloads for contextual profile decisions,
  chat messages, saved-event edges, notification read updates, and match unread
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
- `functions/src/shared/firestore.ts` is still generated from Dart models as a
  transitional Cloud Functions Admin SDK facade. It should not be treated as the
  canonical schema source; JSON Schema contracts own persisted field shape and
  callable payload validation.

## Validation

For the full local contract gate, event:

```bash
./tool/check_data_contract.sh
```

For the fast contract-source check, event:

```bash
node tool/validate_schema_contracts.mjs
```

This checks JSON syntax, schema metadata, local `$ref` targets, prompt catalog
uniqueness, catalog/schema limit alignment, and fixture placement. Generated
TypeScript/Ajv/Dart output is checked by `node tool/generate_schema_contracts.mjs
--check` and by the full data-contract script.
