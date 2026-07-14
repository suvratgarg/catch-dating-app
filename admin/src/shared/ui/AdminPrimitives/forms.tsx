// Slightly above the family target because the generic decision footer and field controls share form-state types.
import type {
  AnchorHTMLAttributes,
  ButtonHTMLAttributes,
  FieldsetHTMLAttributes,
  FormHTMLAttributes,
  HTMLAttributes,
  ImgHTMLAttributes,
  InputHTMLAttributes,
  ReactNode,
  SelectHTMLAttributes,
  TextareaHTMLAttributes,
} from "react";
import {
  CheckboxControl,
  SelectControl,
  TextareaControl,
  TextInputControl,
} from "@catch/web-ui";
import {CheckCircle2, FileWarning, Lock, RefreshCw} from "lucide-react";

import {
  classNames,
  layoutSpanClass,
  type SelectOption,
  type ChipTone,
  type AlertTone,
  type TagTone,
  type MetricTone,
  type MetricVariant,
  type QualityRowTone,
  type AdminOverviewQueueIntent,
  type AdminOverviewSignalTone,
  type RiskTone,
  type DataTableVariant,
  type AdminFormVariant,
  type AdminEditorGridElement,
  type AdminTagRowElement,
  type EmptyStateVariant,
  type AdminLayoutSpan,
  type AdminEyebrowElement,
  type AdminIntakeGateTone,
  type AdminBrandMarkSize,
  type AdminMarketingStepStatus,
  type AdminMarketingNewPostAccent,
  type ReviewDecision,
  type ReviewDecisionHandler,
  type ReviewDecisionResponse,
  type PageHeaderProps,
  type PanelProps,
} from "./shared";

import {AlertRow, Panel} from "./data";
import {AdminDecisionFooterShell, AdminIntakeDecisionActions, AdminIntakeDecisionState} from "./intake";
import {AdminButton} from "./overview";

type FieldValidationProps = {
  descriptionId?: string;
  invalid?: boolean;
};

export function AdminEditorPanel({
  className = "",
  ...props
}: PanelProps) {
  return (
    <Panel
      {...props}
      className={classNames("publishing-editor-panel", className)}
    />
  );
}

export function AdminStateRow({
  label,
  value,
}: {
  label: string;
  value: ReactNode;
}) {
  return (
    <div className="state-row">
      <span>{label}</span>
      <strong>{value}</strong>
    </div>
  );
}

export function StateRow({
  label,
  value,
}: {
  label: string;
  value: ReactNode | null;
}) {
  return (
    <div className="state-row">
      <span>{label}</span>
      <strong>{value ?? "none"}</strong>
    </div>
  );
}

export function AdminTextField({
  className = "marketing-field",
  descriptionId,
  invalid,
  label,
  value,
  onChange,
  ...props
}: {
  className?: string;
  label: string;
  value: string;
  onChange: (value: string) => void;
} & Omit<
  InputHTMLAttributes<HTMLInputElement>,
  "aria-describedby" | "aria-invalid" | "className" | "onChange" | "value"
> & FieldValidationProps) {
  return (
    <label className={className}>
      <span>{label}</span>
      <TextInputControl
        descriptionId={descriptionId}
        invalid={invalid}
        value={value}
        onChange={(event) => onChange(event.target.value)}
        {...props}
      />
    </label>
  );
}

export function TextField({
  className = "field-control",
  descriptionId,
  invalid,
  label,
  onChange,
  span,
  value,
  ...props
}: {
  className?: string;
  label: string;
  onChange: (value: string) => void;
  span?: AdminLayoutSpan;
  value: string;
} & Omit<
  InputHTMLAttributes<HTMLInputElement>,
  "aria-describedby" | "aria-invalid" | "className" | "onChange" | "value"
> & FieldValidationProps) {
  return (
    <label className={classNames(className, layoutSpanClass(span))}>
      <span>{label}</span>
      <TextInputControl
        descriptionId={descriptionId}
        invalid={invalid}
        onChange={(event) => onChange(event.target.value)}
        value={value}
        {...props}
      />
    </label>
  );
}

export function CheckboxField({
  checked,
  className = "check-row",
  label,
  onChange,
  ...props
}: {
  checked: boolean;
  className?: string;
  label: ReactNode;
  onChange: (checked: boolean) => void;
} & Omit<InputHTMLAttributes<HTMLInputElement>, "checked" | "className" | "onChange" | "type">) {
  return (
    <label className={className}>
      <CheckboxControl
        checked={checked}
        onChange={(event) => onChange(event.currentTarget.checked)}
        {...props}
      />
      <span>{label}</span>
    </label>
  );
}

export function AdminOrganizerIntakeCheckboxField({
  className = "",
  ...props
}: Parameters<typeof CheckboxField>[0]) {
  return (
    <CheckboxField
      {...props}
      className={classNames("intake-checkbox-row", className)}
    />
  );
}

export function AdminTextareaField({
  className = "marketing-field",
  descriptionId,
  invalid,
  label,
  rows,
  value,
  onChange,
  ...props
}: {
  className?: string;
  label: string;
  rows: number;
  value: string;
  onChange: (value: string) => void;
} & Omit<
  TextareaHTMLAttributes<HTMLTextAreaElement>,
  "aria-describedby" | "aria-invalid" | "className" | "onChange" | "rows" | "value"
> & FieldValidationProps) {
  return (
    <label className={className}>
      <span>{label}</span>
      <TextareaControl
        descriptionId={descriptionId}
        invalid={invalid}
        rows={rows}
        value={value}
        onChange={(event) => onChange(event.target.value)}
        {...props}
      />
    </label>
  );
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
    <AdminDecisionFooterShell compact={compact}>
      {localDecision ? (
        <AdminIntakeDecisionState>
          <CheckCircle2 size={16} strokeWidth={1.9} />
          <div>
            <strong>{localDecision.decisionStatus.replaceAll("_", " ")}</strong>
            <span>{localDecision.decisionPath}</span>
          </div>
        </AdminIntakeDecisionState>
      ) : (
        <>
          <AdminTextareaField
            label="Review note"
            rows={compact ? 2 : 3}
            value={note}
            onChange={onNoteChange}
          />
          <AdminIntakeDecisionActions>
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
          </AdminIntakeDecisionActions>
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
    </AdminDecisionFooterShell>
  );
}

export function TextareaField({
  className = "field-control",
  descriptionId,
  invalid,
  label,
  onChange,
  rows,
  span,
  value,
  ...props
}: {
  className?: string;
  label: string;
  onChange: (value: string) => void;
  rows: number;
  span?: AdminLayoutSpan;
  value: string;
} & Omit<
  TextareaHTMLAttributes<HTMLTextAreaElement>,
  "aria-describedby" | "aria-invalid" | "className" | "onChange" | "rows" | "value"
> & FieldValidationProps) {
  return (
    <label className={classNames(className, layoutSpanClass(span))}>
      <span>{label}</span>
      <TextareaControl
        descriptionId={descriptionId}
        invalid={invalid}
        onChange={(event) => onChange(event.target.value)}
        rows={rows}
        value={value}
        {...props}
      />
    </label>
  );
}

type SelectFieldProps = {
  className?: string;
  descriptionId?: string;
  invalid?: boolean;
  label: string;
  onChange: (value: string) => void;
  options: SelectOption[];
  value: string;
} & Omit<
  SelectHTMLAttributes<HTMLSelectElement>,
  "aria-describedby" | "aria-invalid" | "className" | "onChange" | "value"
>;

export function AdminMarketingSelectField({
  className = "marketing-field",
  ...props
}: SelectFieldProps) {
  return <SelectField {...props} className={className} />;
}

export function SelectField({
  className = "field-control",
  descriptionId,
  invalid,
  label,
  onChange,
  options,
  value,
  ...props
}: SelectFieldProps) {
  return (
    <label className={className}>
      <span>{label}</span>
      <SelectControl
        descriptionId={descriptionId}
        invalid={invalid}
        onChange={(event) => onChange(event.target.value)}
        value={value}
        {...props}
      >
        {options.map((option) => {
          const value = typeof option === "string" ? option : option.value;
          const label = typeof option === "string" ? option : option.label;
          return <option key={value} value={value}>{label}</option>;
        })}
      </SelectControl>
    </label>
  );
}
