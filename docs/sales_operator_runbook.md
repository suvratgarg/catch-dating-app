---
doc_id: sales_operator_runbook
version: 1.1.0
updated: 2026-10-16
owner: sales_operations
status: active
---

# Sales operator runbook

This runbook is for the Catch lead owner onboarding a referral partner and
running a reviewed outreach queue. The data and authority contracts remain in
`operations_platform.md` and `web_surface_architecture.md`. Keep real prospect
lists, commercial terms, contact details and handoff snapshots outside Git.

## Prepare the handoff

1. Reconcile the existing tracker against the latest email and manually checked
   messaging threads. A blank follow-up date is missing scheduling information,
   not proof that nothing is due. Preserve unknown send dates as unknown.
2. Give every active lead one accountable owner, one concrete next action and
   a review date. Distinguish a proposed handoff from a server-side assignment.
3. Separate active customer commitments from research candidates. Keep delivery,
   contracts, pricing exceptions and existing founder conversations with the
   Catch lead owner until explicitly transferred.
4. Keep researched capability hypotheses separate from prospect-confirmed pain.
   A fit score, published contact address or historical email is not a current
   outreach permission. Review the recipient, channel and exact message.

## Onboard an external referral partner

1. Direct the partner to `/partners` on the deployed Admin origin. They sign in
   using their own phone number, including country code, and SMS verification
   code, or their existing linked Google identity. Never use another person's
   verification code or create a second identity to bypass onboarding.
2. They enter their name, read the bounded referral-role description and select
   **Accept referral role** themselves. Firebase identity alone does not establish
   membership. This role grants neither employee access nor organizer control.
3. The partner can nominate an organizer using its name, city or region, official
   HTTPS site or event link, and truthful relationship context. A nomination
   requires identity review and does not publish or claim an organizer.
4. A Catch administrator reviews canonical organizer identity and the current,
   clear Sales account before offering a lead to an active partner. Use the
   existing assignment action with current revisions, an explicit next action,
   review date and expiry. Do not write membership or assignment documents
   directly. Import procedures are in `operations_platform.md`.

   For a first offer, open **Sales → Hosts → the reviewed host → Overview** and
   use **Offer this lead to a referral partner**. Enter the verified partner account
   UID, next action, local review time, expiry and assignment reason; review the
   exact recipient before offering. This control uses revision zero and cannot
   overwrite any earlier assignment. A failed-precondition or revision rejection
   requires review of the current records. If completion is uncertain, keep the
   form open and use **Retry unchanged offer** to recover the same request. Existing
   assignment transfers and revocations remain separate administrative actions.

5. The partner accepts or declines each offer and records the established channel.
   On accepted leads, they maintain **Next action** and **Review at (UTC)**. Convert
   the intended local time to UTC before saving. Marketing asset access is a
   separate bounded grant.

For older deployments whose partner page offers only Google, the same-origin
Admin root has a phone sign-in entry. A partner can sign in there and return to
`/partners` in the same browser. An employee-access denial at the root does not
grant or remove partner membership. Verify the deployed entry before giving this
fallback; it is not evidence that an SMS or partner onboarding succeeded.

## Work an accepted lead

1. Refresh partner access and read the current assignment and latest contact
   evidence. Stop if access, assignment or reviewed content has changed.
2. Prepare outreach using the permitted observations, capability clauses and
   call to action. Review the exact rendered message and current references.
3. Complete the explicit review and copy flow. Sending remains a separate human
   action on the established channel. Copying does not mean sent or delivered.
4. Record a sent outcome only after actually sending. Retain the thread reference
   and occurrence time, then set the next action and review date.
5. Record a reply, opt-out, rejection or new commitment promptly. Escalate pricing,
   contracts and product promises to the Catch lead owner. Reconcile an uncertain
   save before issuing a different action; use the existing retry/refresh controls.

## End the day

Review new nominations, accepted assignments, unanswered outreach and customer
commitments separately. Every active item should have a next action, accountable
owner and review date. Mark waiting on the prospect only when there is actual
sent evidence and no preceding Catch action remains. No response is not a loss,
and a verbal pilot commitment is not a launched pilot or booked revenue.

## Check readiness

Source tests, merged source, deployed Hosting, deployed Functions, feature gates,
provider setup and a real partner's successful onboarding are separate checks.
Verify each required boundary before announcing a live handoff. Manual research
and message preparation can proceed while optional model preparation or final
prose-editing enhancements are unfinished. Neither provider availability nor
an approved draft authorizes automatic outreach.
