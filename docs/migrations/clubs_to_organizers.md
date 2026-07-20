---
doc_id: clubs_to_organizers_migration
version: 1.0.0
updated: 2026-07-20
owner: data_platform
status: active
---

# Clubs To Organizers Migration

This runbook owns the one-time authority cutover from `clubs` to `organizers`.
`Organizer` is the durable entity; `club` is one value of its required
`organizerType`. The machine-readable state lives in
`contracts/migrations/clubs_to_organizers.json`.

The migration is additive and idempotent. It does not delete legacy documents,
Storage objects, callable wrappers, fields, indexes, or rules. Retirement is a
later operation that requires released-client evidence and a separate explicit
approval.

## Canonical Type Model

`organizers/{organizerId}.organizerType` is a closed enum:

| Type | Use it for | Typical examples |
|---|---|---|
| `club` | A membership-oriented group organized around a recurring activity or identity. | run club, book club, cycling club |
| `community` | A broader social community whose identity is not primarily a formal club. | neighborhood group, creator community, interest collective |
| `individual` | A person publishing events in their own professional capacity. | independent host, coach, facilitator |
| `eventProducer` | An organization primarily producing programmed events or experiences. | singles-events company, festival producer, workshop series |
| `venue` | A place that hosts or curates events under its own identity. | cafe, studio, bar, coworking space |
| `brand` | A commercial or institutional brand organizing community activity. | sports brand, university, employer community |

The values are operational identity, not marketing copy. The optional
`publicCategoryLabel` can carry a reviewed display label without expanding the
enum. Legacy records with no usable classification become `club`.
`creatorCommunity` maps to `community`; `eventOrganizer` maps to
`eventProducer`; `venue` and `brand` retain their meaning.

The organizer owner can edit `organizerType` in the Hosts app. Managers can see
the field but cannot change it. Every change writes `organizerTypeUpdatedAt`
and `organizerTypeUpdatedByUid`; public category text remains independently
reviewed.

## Authority And Compatibility

| Concern | Canonical authority | Temporary compatibility projection |
|---|---|---|
| Entity | `organizers/{organizerId}` | `clubs/{clubId}` |
| Owner/manager relationship | `organizerTeamMemberships/{organizerId_uid}` | host-role `clubMemberships` and `clubHostClaims` |
| Consumer relationship | `organizerFollows/{organizerId_uid}` | member-role `clubMemberships/{clubId_uid}` |
| Posts | `organizers/{organizerId}/posts/{postId}` | `clubs/{clubId}/posts/{postId}` |
| Claim review | `organizerClaimRequests/{requestId}` | `clubClaimRequests/{requestId}` |
| Schedule lock | `organizerScheduleLocks/{lockId}` | `clubScheduleLocks/{lockId}` |
| Media | `organizers/{organizerId}/...` | `clubs/{clubId}/...` |
| Dependent identity | `organizerId` | `clubId` |
| Public route | `/organizers/.../` | existing legacy redirects only |

New Flutter, React, and Functions code must use the canonical column. Legacy
fields are mirrors for released clients and warehouse continuity, not alternate
sources of truth. `tool/check_organizer_nomenclature.mjs` enforces the selected
cutover points.

## What The Migration Copies

`tool/data/migrate_clubs_to_organizers.mjs` inventories and plans:

- every `clubs/{id}` document, defaulting its type to `club` and deriving
  `organizerPhotos`, `followerCount`, type audit fields, and organizer route;
- owner/co-host membership edges into `organizerTeamMemberships` and member
  edges into `organizerFollows`;
- `clubHostClaims` not already represented by a team edge;
- claim requests, schedule locks, nested posts, and organizer route
  reservations;
- `organizerId` on events, reviews, matches, notifications, broadcasts,
  invite/access/participation/waitlist documents, Event Success documents, and
  user schedule locks;
- all Storage objects below `clubs/` into the equivalent `organizers/` path.

An existing canonical value must either match the legacy source or be missing.
The tool reports a blocker instead of overwriting a different value. Existing
Storage targets require a matching CRC32C or MD5 checksum; different or
incomparable objects block apply.

## Environment Run Order

Complete this sequence independently in dev, staging, and production:

1. Deploy the additive contracts, Firestore indexes, Firestore rules, Storage
   rules, and canonical Functions. Do not remove legacy support.
2. Run a Firestore and Storage dry run and retain the JSON output:

   ```sh
   node tool/data/migrate_clubs_to_organizers.mjs \
     --env dev --include-storage --json
   ```

3. Resolve every blocker. Review source counts, planned writes by kind, and
   Storage copy count. Choose a new, unused backup path.
4. Apply only after the environment and plan have been explicitly approved:

   ```sh
   node tool/data/migrate_clubs_to_organizers.mjs \
     --env dev \
     --include-storage \
     --apply \
     --confirm-migration \
     --backup-file artifacts/migrations/dev-clubs-to-organizers.json
   ```

   Production additionally requires `--allow-prod`.
5. The apply command rereads Firestore and Storage. It succeeds only when the
   second plan contains zero writes and zero blockers.
6. Deploy Flutter and React clients that read organizer authority. Exercise
   discovery, follow/unfollow, organizer detail, owner edit including type,
   manager access, event creation/edit, posts, claim/review, analytics, admin
   publishing, media upload, and public listing routes.
7. Monitor missing-document, permission, callable-not-found, Storage, search,
   and analytics errors across at least the supported released-client window.

Do not run apply against any shared environment from an ordinary code-change
session. The backup file and explicit confirmation flags are required, and the
production mutation must be separately approved.

## Parity Evidence

Before calling an environment migrated, record:

- legacy club count equals canonical organizer count for the migrated set;
- every canonical organizer validates against `organizers.schema.json` and has
  one allowed `organizerType`;
- active host/member legacy edges reconcile with active team/follow edges;
- every dependent record with `clubId` has the same `organizerId`;
- nested post counts and content match;
- route reservations point at `organizers/{id}`;
- Storage source/target object counts and checksums match;
- the migration's post-apply plan is empty;
- organizer-first app, website, and admin smoke flows pass.

The legacy side remains a compatibility projection after parity. A later
retirement plan must prove fallback-read volume is zero, all supported clients
are organizer-aware, and no operational tool still treats `clubs` as primary.

## Failure And Recovery

The tool never deletes source data. If it stops on a blocker, correct the
specific canonical conflict or source defect and rerun the dry run. If an apply
fails partway through, retain the backup, do not delete successful target
writes, and rerun: equal writes are idempotent and remaining writes are planned
again. A checksum conflict is investigated manually; it is never resolved by
blind overwrite.

Rollback during the compatibility window means moving client reads back to the
legacy projection while preserving canonical data for diagnosis. It does not
mean deleting `organizers` or copied media. Any destructive rollback needs its
own exact target list, export, approval, and receipt.
