# Event seat authority core

This module is unregistered server-only logic. It is not a migration, callable,
Firestore schema, or deployed seat policy. The calling operation must prepare
the seat plan inside the **same Firestore transaction** as its organizer, event,
admission and payment reads, then apply
the frozen plan only after all other authority reads and before its confirmed
booking, attendee and receipt writes. A plan can apply only to its preparing
transaction. The adapter must map each event ledger, canonical identity
reservation and request receipt to a
deterministic, client-denied document; optimistic transaction retries serialize
the ledger revision and capacity check. Its `createReceipt` must be create-only.

The caller supplies a current, explicit capacity and capacity policy revision.
The ledger must be marked `ready` with a positive migration revision only after
all historical Catch participations and Host/imported attendees have been
reconciled into one occupied count and one reservation per unique person.
Unknown, missing, revoked or unreconciled ledgers fail closed. The core cannot
make a basic event free or assign capacity one from missing setup fields.

`resolveIdentity` is an adapter-required in-transaction authority. It must
resolve all known verified phone, linked UID, imported reference and CRM merge
aliases to one opaque stable key, and return a revision that changes on an
identity merge. The current attendee ID algorithm can converge a phone import
with a later Catch booking, while UID-only records may use another key. Never
pass a raw row ID or assume those identities are disjoint. Identity merges,
legacy count repairs, and capacity policy changes need a separately authorized
reconciliation operation that updates reservations, occupied count, revisions,
and readiness together before further reservations. This core cannot certify
that reconciliation happened; the migration owner establishes the ready marker.

A reserve increments occupied once. A release decrements once and retains its
reservation and immutable receipt. Exact request replay returns the historical
receipt plus *current* active state; it never reinstates a released seat.
Fresh retries after a release require the latest ledger and reservation
revisions. A reservation is a seat, not proof of payment, approval, consent,
message delivery, or check-in. The integration must bind its own admission
receipt to the source offer generation and explicit payment terms snapshot.
