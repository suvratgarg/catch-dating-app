import {Handshake} from "lucide-react";
import {useState} from "react";
import {AdminButton, AdminForm, CheckboxField, Panel, TextareaField, TextField} from "../../../shared/ui/AdminPrimitives";
import {useAdminOperationPending} from "../../../shared/pendingOperation";
import {useSalesPartnerOfferController} from "../controllers/useSalesPartnerOfferController";

function PartnerOffer({actorUid, organizerId, organizerName}: {
  actorUid: string; organizerId: string; organizerName: string;
}) {
  const c = useSalesPartnerOfferController(actorUid, organizerId);
  const operationPending = useAdminOperationPending();
  const [partnerUid, setPartnerUid] = useState(""); const [nextAction, setNextAction] = useState("");
  const [reviewAt, setReviewAt] = useState(""); const [expiresAt, setExpiresAt] = useState("");
  const [reason, setReason] = useState(""); const [reviewed, setReviewed] = useState(false);
  const disabled = operationPending || !!c.ticket || !!c.offeredTo;
  const change = (setter: (value: string) => void) => (value: string) => {setter(value); setReviewed(false);};
  return <Panel title="Offer this lead to a referral partner" icon={<Handshake size={18} />}>
    <p>This creates the first partner offer for {organizerName}. It requires an active partner membership
      and a reviewed, unrestricted Sales account. Existing assignments are never overwritten here.</p>
    <p>The partner can see this organizer and next action, then accept or decline. An offer grants no
      organizer control or permission to send messages.</p>
    {c.error && <p role="alert">{c.error}</p>}
    {c.offeredTo ? <p role="status">Lead offered to account {c.offeredTo}. Ask the partner to refresh their workspace.</p> :
    <AdminForm onSubmit={(event) => {
      event.preventDefault(); if (!reviewed || disabled) return;
      void c.offer({partnerUid, nextAction, reason,
        reviewAt: Number.isFinite(Date.parse(reviewAt)) ? new Date(reviewAt).toISOString() : "",
        expiresAt: Number.isFinite(Date.parse(expiresAt)) ? new Date(expiresAt).toISOString() : ""});
    }}>
      <TextField label="Verified partner account UID" value={partnerUid} onChange={change(setPartnerUid)} disabled={disabled} />
      <TextareaField label="Next action for the partner" value={nextAction} onChange={change(setNextAction)} disabled={disabled} rows={3} />
      <TextField label="Review at (your local time)" type="datetime-local" value={reviewAt} onChange={change(setReviewAt)} disabled={disabled} />
      <TextField label="Assignment expires (your local time)" type="datetime-local" value={expiresAt} onChange={change(setExpiresAt)} disabled={disabled} />
      <TextareaField label="Reason for this assignment" value={reason} onChange={change(setReason)} disabled={disabled} rows={2} />
      <CheckboxField label={`I reviewed this organizer identity and the exact partner account ${partnerUid || "above"}`} checked={reviewed} onChange={setReviewed} disabled={disabled} />
      <AdminButton type="submit" variant="primary" disabled={disabled || !reviewed || !partnerUid.trim() || !nextAction.trim() || !reason.trim() || !reviewAt || !expiresAt}>Offer lead</AdminButton>
    </AdminForm>}
    {c.ticket && <AdminButton disabled={operationPending} onClick={() => void c.retry()}>Retry unchanged offer</AdminButton>}
  </Panel>;
}
export function renderSalesPartnerOffer(actorUid: string, organizerId: string, organizerName: string) {
  return <PartnerOffer key={`${actorUid}:${organizerId}`} actorUid={actorUid} organizerId={organizerId} organizerName={organizerName} />;
}
