import {
  CheckCircle2,
  CircleDollarSign,
  MessageSquareText,
  ShieldCheck,
} from "lucide-react";
import {
  AdminButton,
  AdminTag,
  AdminTagList,
  AdminToolbar,
  AdminWorkbenchStack,
  AlertRow,
  Panel,
  QualityList,
  SelectField,
  StateRow,
  TextareaField,
  TextField,
} from "../../../shared/ui/AdminPrimitives";
import type {
  MessagingBudgetController,
  MessagingBudgetPurpose,
  MessagingBudgetRoute,
} from "../controllers/useMessagingBudgetController";

const routeOptions: Array<{label: string; value: MessagingBudgetRoute}> = [
  {label: "Catch SMS", value: "catchEventSms"},
  {label: "Catch RCS", value: "catchEventRcs"},
  {label: "Organizer WhatsApp", value: "organizerEventWhatsapp"},
];

const purposeOptions: Array<{label: string; value: MessagingBudgetPurpose}> = [
  {label: "Joining update", value: "joiningUpdate"},
  {label: "Joining instructions", value: "joiningInstructions"},
  {label: "Plan changed", value: "planChanged"},
  {label: "Event cancelled", value: "eventCancelled"},
  {label: "Event finished", value: "eventFinished"},
  {label: "Guest requirement", value: "guestRequirement"},
  {label: "Assignment changed", value: "assignmentChanged"},
  {label: "Participation check", value: "participationCheck"},
  {label: "Follow-up", value: "followUp"},
];

const decisionOptions = [
  {label: "Hold for more evidence", value: "hold"},
  {label: "Approve ceilings", value: "approve"},
  {label: "Reject proposal", value: "reject"},
];

export function renderMessagingBudgetPanel(controller: MessagingBudgetController) {
  const review = controller.reviewResult?.review ?? null;
  const decision = controller.reviewResult?.decision ?? null;
  return (
    <Panel
      span={2}
      icon={<MessageSquareText size={18} strokeWidth={1.9} />}
      title="Event messaging budget"
      action="Finance-controlled"
    >
      <AdminWorkbenchStack compact>
        <AlertRow
          icon={<ShieldCheck size={16} strokeWidth={1.9} />}
          title="Review and staging only"
          tone="neutral"
        >
          This workflow can record a decision and stage paused ceilings. It
          cannot spend, send a message, contact a provider, or activate a worker.
        </AlertRow>
        <AdminToolbar>
          <TextField
            label="Organizer ID"
            onChange={(value) => controller.setScope("organizerId", value)}
            value={controller.scope.organizerId}
          />
          <TextField
            label="Event ID"
            onChange={(value) => controller.setScope("eventId", value)}
            value={controller.scope.eventId}
          />
          <SelectField
            label="Route"
            onChange={(value) => controller.setScope(
              "routeId",
              value as MessagingBudgetRoute
            )}
            options={routeOptions}
            value={controller.scope.routeId}
          />
          <TextField
            label="Sender ID"
            onChange={(value) => controller.setScope("senderId", value)}
            value={controller.scope.senderId}
          />
          <SelectField
            label="Message purpose"
            onChange={(value) => controller.setScope(
              "purpose",
              value as MessagingBudgetPurpose
            )}
            options={purposeOptions}
            value={controller.scope.purpose}
          />
          <AdminButton
            disabled={controller.isReviewing}
            loading={controller.isReviewing}
            loadingLabel="Reviewing"
            onClick={() => void controller.review()}
            variant="primary"
          >
            Review current setup
          </AdminButton>
        </AdminToolbar>

        {review ? (
          <>
            <QualityList>
              <StateRow label="Runtime" value={runtimeLabel(review.runtime)} />
              <StateRow
                label="Sender"
                value={review.sender ?
                  `${review.sender.displayName} · ${review.sender.availability}` :
                  "Unavailable"}
              />
              <StateRow
                label="Budget evidence"
                value={review.budgets.kind === "reviewed" ?
                  `${review.budgets.currency} · ${budgetLabel(review.budgets.event)} event · ${budgetLabel(review.budgets.senderDay)} sender-day` :
                  "Sender unavailable"}
              />
              <StateRow
                label="Current decision"
                value={decision ?
                  `${decision.decisionStatus} · revision ${decision.revision}` :
                  "No decision recorded"}
              />
            </QualityList>
            <AdminTagList>
              <AdminTag tone="neutral">No spending authority</AdminTag>
              <AdminTag tone="neutral">No dispatch authority</AdminTag>
              <AdminTag tone="neutral">Revision-fenced</AdminTag>
            </AdminTagList>
            <AdminToolbar>
              <SelectField
                label="Finance decision"
                onChange={(value) => controller.setDecisionKind(
                  value as MessagingBudgetController["decisionKind"]
                )}
                options={decisionOptions}
                value={controller.decisionKind}
              />
              {controller.decisionKind === "approve" ? (
                <>
                  <TextField
                    inputMode="decimal"
                    label={`Event ceiling (${review.budgets.kind === "reviewed" ? review.budgets.currency : "currency"})`}
                    onChange={controller.setEventLimit}
                    placeholder="250.00"
                    value={controller.eventLimit}
                  />
                  <TextField
                    inputMode="decimal"
                    label={`Sender-day ceiling (${review.budgets.kind === "reviewed" ? review.budgets.currency : "currency"})`}
                    onChange={controller.setSenderDayLimit}
                    placeholder="500.00"
                    value={controller.senderDayLimit}
                  />
                  <TextField
                    label="Approval expires"
                    onChange={controller.setValidUntil}
                    type="datetime-local"
                    value={controller.validUntil}
                  />
                </>
              ) : null}
            </AdminToolbar>
            <TextareaField
              label="Finance review note"
              onChange={controller.setDecisionNote}
              rows={3}
              value={controller.decisionNote}
            />
            {controller.decisionDisabledReason ? (
              <AlertRow
                icon={<CircleDollarSign size={16} strokeWidth={1.9} />}
                title="Decision not ready"
                tone="warning"
              >
                {controller.decisionDisabledReason}
              </AlertRow>
            ) : null}
            <AdminButton
              disabled={Boolean(controller.decisionDisabledReason) || controller.isDeciding}
              loading={controller.isDeciding}
              loadingLabel="Recording"
              onClick={() => void controller.decide()}
              variant="primary"
            >
              Record finance decision
            </AdminButton>
          </>
        ) : null}

        {decision?.decisionStatus === "approved" ? (
          <Panel
            icon={<CheckCircle2 size={17} strokeWidth={1.9} />}
            title="Stage approved ceilings"
            action={`Revision ${decision.revision}`}
          >
            <AdminWorkbenchStack compact>
              <TextareaField
                label="Staging note"
                onChange={controller.setStagingNote}
                rows={2}
                value={controller.stagingNote}
              />
              {controller.stageDisabledReason ? (
                <AlertRow
                  icon={<ShieldCheck size={16} strokeWidth={1.9} />}
                  title="Staging not ready"
                  tone="warning"
                >
                  {controller.stageDisabledReason}
                </AlertRow>
              ) : null}
              <AdminButton
                disabled={Boolean(controller.stageDisabledReason) || controller.isStaging}
                loading={controller.isStaging}
                loadingLabel="Staging"
                onClick={() => void controller.stage()}
                variant="primary"
              >
                Stage paused ceilings
              </AdminButton>
            </AdminWorkbenchStack>
          </Panel>
        ) : null}

        {controller.stagedResult ? (
          <AlertRow
            icon={<CheckCircle2 size={16} strokeWidth={1.9} />}
            title="Ceilings staged in paused status"
            tone="success"
          >
            Event and sender-day revisions were recorded. The provider was not
            contacted, the worker remains inactive, and dispatch remains blocked.
          </AlertRow>
        ) : null}
      </AdminWorkbenchStack>
    </Panel>
  );
}

function runtimeLabel(runtime: NonNullable<
  MessagingBudgetController["reviewResult"]
>["review"]["runtime"]): string {
  const selection = runtime.appliesToPurpose ?
    runtime.selected ? "selected" : "not selected" : "not required";
  return `${runtime.status} · ${selection} · revision ${runtime.revision ?? "none"}`;
}

function budgetLabel(budget: {
  kind: "unavailable";
  reason: "missing" | "invalid";
} | {
  kind: "recorded";
  issue: string | null;
  revision: number;
}): string {
  return budget.kind === "unavailable" ? budget.reason :
    `${budget.issue ?? "ready"} (r${budget.revision})`;
}
