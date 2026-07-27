import type {
  OrganizerEventBlockerResolution,
  OrganizerEventImportBlockerCode,
} from "../../../../shared/types/adminTypes";
import type * as Intake from "../types/organizerIntakeTypes";

export type BlockerResolutionChoice =
  "unresolved" | "resolved" | "waived";
export type BlockerResolutionChoices = Partial<Record<
  OrganizerEventImportBlockerCode,
  BlockerResolutionChoice
>>;

const blockerPolicyDecisionIds: Record<
  OrganizerEventImportBlockerCode,
  string
> = {
  missing_exact_coordinates:
    "policy-external-event-location-provider-policy",
  missing_end_time: "policy-external-event-defaults-policy",
  missing_location_detail:
    "policy-external-event-location-provider-policy",
  requires_event_defaults_policy:
    "policy-external-event-defaults-policy",
  requires_owner_safe_copy_review:
    "policy-external-event-import-write-policy",
  duplicate_normalized_event_key:
    "policy-external-event-import-write-policy",
};

export function blockerResolutionsFromChoices(
  blockerCodes: OrganizerEventImportBlockerCode[],
  choices: BlockerResolutionChoices,
  note: string
): OrganizerEventBlockerResolution[] {
  return blockerCodes.flatMap((blockerCode) => {
    const outcome = choices[blockerCode];
    if (outcome !== "resolved" && outcome !== "waived") return [];
    return [{
      blockerCode,
      outcome,
      policyGapDecisionId: outcome === "waived" ?
        blockerPolicyDecisionIds[blockerCode] :
        null,
      note: note.trim(),
    }];
  });
}

export function governedBlockersForCandidate(
  candidate: Intake.OrganizerExternalEventCandidate,
  queue: Intake.OrganizerExternalEventCandidateQueue
): OrganizerEventImportBlockerCode[] {
  const blockers = new Set<OrganizerEventImportBlockerCode>();
  const known = new Set(Object.keys(blockerPolicyDecisionIds));
  for (const blocker of candidate.blockers) {
    if (known.has(blocker)) {
      blockers.add(blocker as OrganizerEventImportBlockerCode);
    }
  }
  if (candidate.endAt === null) blockers.add("missing_end_time");
  if (!candidate.location.name && !candidate.location.address) {
    blockers.add("missing_location_detail");
  }
  if (
    typeof candidate.location.latitude !== "number" ||
    typeof candidate.location.longitude !== "number"
  ) {
    blockers.add("missing_exact_coordinates");
  }
  blockers.add("requires_event_defaults_policy");
  blockers.add("requires_owner_safe_copy_review");
  if (queue.duplicateEventKeys.some((entry) =>
    entry.candidateIds.includes(candidate.candidateId))) {
    blockers.add("duplicate_normalized_event_key");
  }
  return [...blockers].sort();
}

export function renderOrganizerEventBlockerResolutionFields({
  blockerCodes,
  choices,
  disabled,
  onChange,
}: {
  blockerCodes: OrganizerEventImportBlockerCode[];
  choices: BlockerResolutionChoices;
  disabled: boolean;
  onChange: (choices: BlockerResolutionChoices) => void;
}) {
  if (blockerCodes.length === 0) return null;
  return (
    <AdminIntakeSection>
      <AdminIntakeSectionTitle>
        Event-scoped blocker decisions
      </AdminIntakeSectionTitle>
      <AdminOrganizerCurationControlGrid>
        {blockerCodes.map((blockerCode) => (
          <SelectField
            disabled={disabled}
            key={blockerCode}
            label={blockerCode.replaceAll("_", " ")}
            onChange={(value) => onChange({
              ...choices,
              [blockerCode]: value as BlockerResolutionChoice,
            })}
            options={[
              {label: "Unresolved", value: "unresolved"},
              {label: "Resolved for this event", value: "resolved"},
              {label: "Waive with accepted policy", value: "waived"},
            ]}
            value={choices[blockerCode] ?? "unresolved"}
          />
        ))}
      </AdminOrganizerCurationControlGrid>
    </AdminIntakeSection>
  );
}
import {
  AdminIntakeSection,
  AdminIntakeSectionTitle,
  AdminOrganizerCurationControlGrid,
  SelectField,
} from "../../../../shared/ui/AdminPrimitives";
