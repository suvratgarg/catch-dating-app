import {MessageCircle} from "lucide-react";
import {AdminButton, CheckboxField, Panel, TextareaField, TextField} from
  "../../../shared/ui/AdminPrimitives";
import {useAdminOperationPending} from "../../../shared/pendingOperation";
import {useCatchWhatsappTrialController} from
  "../controllers/useCatchWhatsappTrialController";
import {catchWhatsappTrialEnabled, type CatchTrialApi, type CatchTrialScope} from
  "../api/catchWhatsappTrialRepository";

export function CatchWhatsappTrialWorkspace({scope, enabled = catchWhatsappTrialEnabled(), api}: {
  scope: CatchTrialScope; enabled?: boolean; api?: CatchTrialApi;
}) {
  const controller = useCatchWhatsappTrialController({scope, enabled, api});
  const operationPending = useAdminOperationPending();
  const locked = controller.busy || operationPending;
  const canEdit = enabled && !locked && !controller.terminal &&
    Boolean(controller.inbound) && !controller.expired;
  return <Panel title="WhatsApp support trial" icon={<MessageCircle size={18} />}>
    {!enabled ? <p>This controlled support trial is not enabled.</p> : <>
      <p>Review one approved support request, then confirm the exact reply.</p>
      <TextField label="Support request ID" value={controller.eventId}
        onChange={controller.setEventId} maxLength={69}
        disabled={locked || controller.terminal} autoComplete="off" />
      <AdminButton onClick={() => void controller.review()}
        disabled={locked || controller.terminal ||
          !/^cwhe_[a-f0-9]{64}$/u.test(controller.eventId)}>
        Review request
      </AdminButton>
      {controller.inbound ? <>
        <TextareaField label="Received support request"
          value={controller.inbound.inboundText} onChange={() => undefined}
          readOnly rows={4} />
        <p>Reply before {new Date(controller.inbound.deadlineMillis)
          .toLocaleString()}.</p>
        <TextareaField label="Exact reply" value={controller.replyBody}
          onChange={controller.editReply} rows={4} maxLength={4096}
          disabled={!canEdit} />
        <CheckboxField
          label="This message requests support, and I approve the exact reply shown."
          checked={controller.phase === "confirmed"}
          onChange={controller.confirm} disabled={!canEdit} />
        <AdminButton variant="primary" onClick={() => void controller.send()}
          disabled={!canEdit || controller.phase !== "confirmed"}>
          Send this reply once
        </AdminButton>
      </> : null}
      {controller.expired ? <p role="alert">The reply window has expired.</p> : null}
      {controller.phase === "unknown" ? <p role="status">
        This attempt is reserved. Do not send again while its outcome is unconfirmed.
      </p> : null}
      {controller.result ? <p role="status">
        Reply recorded. Delivery status: {controller.result.deliveryStatus}.
      </p> : null}
    </>}
    {controller.error ? <p role="alert">{controller.error}</p> : null}
  </Panel>;
}
