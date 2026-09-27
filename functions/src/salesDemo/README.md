# Private sales demo server boundary

The exports in `callables.ts` are not registered in `functions/src/index.ts` yet.
The integration owner must add that wiring after reviewing Firestore rules,
collection ownership, callable deployment settings, and the website route.
No live demo has been issued or activated by this source change.

`getSalesDemoPreview({invitationId})` returns only a reviewed preview,
`interactiveAvailable`, expiry, and a server-owned simulation notice. It is an
anonymous, read-only callable. A page fetch or unfurl creates no session,
activity, budget use, or opened counter. The opaque invitation ID can appear in
a private URL because it reveals only that minimal approved projection. App
Check is required even though Firebase Auth is not.

`startSalesDemo({invitationId,grantToken,requestId})`,
`getSalesDemoSession({sessionId,grantToken})`, and
`advanceSalesDemo({sessionId,grantToken,requestId,expectedRevision,action,choice?})`
require Firebase Auth and App Check. The server verifies the current Auth user
and the verified token email or phone claim against the invitation's keyed
contact digest. A missing binding makes an invitation preview-only. A contact
entered in a form, a client boolean, or organizer membership is never accepted
as proof. If a person's verified endpoint is unavailable or outdated, an
operator must verify and issue a new bound invitation; the trial cannot repair
or claim their organizer account.

The grant token is returned to the Admin Owner on invitation issuance and exact
same-key replay. Store it only as a digest in Firestore. A website may read it
from a URL fragment, remove that fragment from browser history immediately,
keep it only in memory, and supply it in callable request bodies. Never place
it in a query string, localStorage, analytics, receipt, or log. The dedicated
Secret Manager secret `SALES_DEMO_GRANT_KEY` must contain at least 32 random
bytes encoded as base64url. There is no test or production fallback. Rotating
this key invalidates existing grants and contact digests; issuance replay then
fails clearly so an owner can issue a new invitation. Revoke an invitation to
stop all future trial mutations without rotating every grant.

An Admin Owner can save, review, withdraw, and read a blueprint; issue, revoke,
and read an invitation. Each management mutation uses a stable request ID and
expected revision, writes one immutable receipt and audit event atomically,
and rechecks current owner claims even on replay. Editing a reviewed blueprint
creates a new draft revision and invalidates old invitations. A trusted
server-owned `salesDemoCapabilities/synthetic_forms_v1` document must be
present, enabled, and carry current capability and evidence revisions from the
product capability owner. Blueprint
save/review/issue, preview, start, and every trial action recheck that current
gate. Absence or a changed capability or evidence revision fails closed. No
browser field can enable it.

Sessions are limited to one active session per invitation and at most three
sessions for the invitation's lifetime. Start and actions use transactional
idempotency receipts. Session actions permit only synthetic application review,
reply preparation, guest admission, and assistance request. A fixed synthetic
applicant has no email, phone, user ID, production guest ID, payment, or outbox
reference. This is a separate Forms practice adapter: the existing rehearsal
engine's pure attendance and Room reducers do not represent application review
or reply preparation, and its manager handlers can stamp production rehearsal
milestones. No rehearsal handler is called here. The recorded form capability
and field mapping reviews distinguish exact support, manual adaptation,
retained tools, and unsupported logic; the demo does not import a real form.

The scheduled `expireSalesDemos` export deletes expired synthetic sessions and
their trial receipts in bounded batches. Blueprints and issuance audit remain
for review. All five `salesDemo*` collections are server-only and need explicit
client SDK deny rules and ownership catalog registration before deployment.
Production promotion is not implemented: no trial action publishes, messages,
charges, grants organizer authority, copies configuration, or writes a product
record. The server records only confirmed start/action receipts. Sales activity
projection from those receipts is a separate integration; a preview fetch is
never a confirmed interaction.
