import {CheckCircle2, FileWarning} from "lucide-react";
import {
  AdminButton,
  AdminTextareaField,
  AlertRow,
} from "./AdminPrimitives";

type ReviewDecision = "approve" | "needs_changes" | "hold" | "reject" |
  "export_ready";

type ReviewDecisionHandler = (input: {
  targetType: string;
  targetId: string;
  decision: ReviewDecision;
  edits?: Record<string, unknown>;
  defaultNote: string;
}) => Promise<void>;

interface ReviewDecisionResponse {
  decisionStatus: string;
  decisionPath: string;
}

export function DecisionFooter<TTargetType extends string = string>({
  approvalDisabledReason,
  compact = false,
  defaultNote,
  edits,
  inFlight,
  localDecision,
  note,
  showExportReady = false,
  targetId,
  targetType,
  onDecision,
  onNoteChange,
}: {
  approvalDisabledReason?: string;
  compact?: boolean;
  defaultNote: string;
  edits: Record<string, unknown>;
  inFlight?: boolean;
  localDecision?: ReviewDecisionResponse;
  note: string;
  showExportReady?: boolean;
  targetId: string;
  targetType: TTargetType;
  onDecision: (
    input: Omit<Parameters<ReviewDecisionHandler>[0], "targetType"> & {
      targetType: TTargetType;
    }
  ) => Promise<void>;
  onNoteChange: (value: string) => void;
}) {
  const approveDisabled = Boolean(inFlight || approvalDisabledReason);
  return (
    <div className={`marketing-decision-footer ${compact ? "compact" : ""}`}>
      {localDecision ? (
        <div className="intake-decision-state">
          <CheckCircle2 size={16} strokeWidth={1.9} />
          <div>
            <strong>{localDecision.decisionStatus.replaceAll("_", " ")}</strong>
            <span>{localDecision.decisionPath}</span>
          </div>
        </div>
      ) : (
        <>
          <AdminTextareaField
            label="Review note"
            rows={compact ? 2 : 3}
            value={note}
            onChange={onNoteChange}
          />
          <div className="intake-decision-actions">
            <AdminButton
              disabled={approveDisabled}
              onClick={() => onDecision({
                targetType,
                targetId,
                decision: "approve",
                edits,
                defaultNote,
              })}
              variant="primary"
            >
              {inFlight ? "Saving" : "Approve"}
            </AdminButton>
            <AdminButton
              disabled={inFlight}
              onClick={() => onDecision({
                targetType,
                targetId,
                decision: "needs_changes",
                edits,
                defaultNote,
              })}
            >
              Needs changes
            </AdminButton>
            <AdminButton
              disabled={inFlight}
              onClick={() => onDecision({
                targetType,
                targetId,
                decision: "hold",
                edits,
                defaultNote,
              })}
            >
              Hold
            </AdminButton>
            <AdminButton
              disabled={inFlight}
              onClick={() => onDecision({
                targetType,
                targetId,
                decision: "reject",
                edits,
                defaultNote,
              })}
            >
              Reject
            </AdminButton>
            {showExportReady ? (
              <AdminButton
                disabled={approveDisabled}
                onClick={() => onDecision({
                  targetType,
                  targetId,
                  decision: "export_ready",
                  edits,
                  defaultNote,
                })}
              >
                Export ready
              </AdminButton>
            ) : null}
          </div>
          {approvalDisabledReason ? (
            <AlertRow
              icon={<FileWarning size={16} strokeWidth={1.9} />}
              title="Approval blocked"
              tone="warning"
            >
              {approvalDisabledReason}
            </AlertRow>
          ) : null}
        </>
      )}
    </div>
  );
}
