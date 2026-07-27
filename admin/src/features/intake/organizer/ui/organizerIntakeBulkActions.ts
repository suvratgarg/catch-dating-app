import type {AdminIntakeBulkAction} from
  "../../../../shared/ui/AdminPrimitives";
import {
  emptyOrganizerSurfaceChecklist,
  organizerSurfaceChecklistReady,
  organizerVisibilityFormForItem,
  publicationPacketReady,
} from "../controllers/organizerIntakeHelpers";
import type {OrganizerIntakeController} from
  "../controllers/useOrganizerIntakeController";
import type * as Intake from "../types/organizerIntakeTypes";

export type OrganizerWorkbenchEntry =
  | {
    id: string;
    kind: "entity";
    item: Intake.OrganizerIntakeItem;
  }
  | {
    id: string;
    kind: "candidate";
    candidate: Intake.OrganizerSearchCandidate;
  };

function canApprove(
  item: Intake.OrganizerIntakeItem,
  packet: Intake.OrganizerPublicationReviewPacket | undefined,
  visibilityForms: Record<string, Intake.OrganizerVisibilityFormState>,
  surfaceChecklists: Record<string, Intake.OrganizerSurfaceChecklistState>,
  reportAcknowledgements: Record<string, boolean>
) {
  const visibility = visibilityForms[item.entityId] ??
    organizerVisibilityFormForItem(item);
  const checklist = surfaceChecklists[item.entityId] ??
    emptyOrganizerSurfaceChecklist();
  const manualReports =
    packet?.evidenceSummary.manualReportsWithoutArtifacts ?? 0;
  return publicationPacketReady(packet) &&
    organizerSurfaceChecklistReady(visibility, checklist) &&
    (manualReports === 0 || reportAcknowledgements[item.entityId] === true);
}

export function buildOrganizerIntakeBulkActions({
  entries,
  handleAttachCandidate,
  handleDecision,
  manualReportAcknowledgements,
  publicationPacketByEntity,
  surfaceChecklists,
  visibilityForms,
}: {
  entries: OrganizerWorkbenchEntry[];
  handleAttachCandidate: OrganizerIntakeController["handleAttachCandidate"];
  handleDecision: OrganizerIntakeController["handleDecision"];
  manualReportAcknowledgements: Record<string, boolean>;
  publicationPacketByEntity: Map<
    string,
    Intake.OrganizerPublicationReviewPacket
  >;
  surfaceChecklists: Record<string, Intake.OrganizerSurfaceChecklistState>;
  visibilityForms: Record<string, Intake.OrganizerVisibilityFormState>;
}): AdminIntakeBulkAction[] {
  const entryById = new Map(entries.map((entry) => [entry.id, entry]));
  const applyEntityDecision = async (
    ids: readonly string[],
    decision: "approve_public" | "hold" | "suppress"
  ) => {
    const appliedIds: string[] = [];
    const failures: Array<{id: string; reason: string}> = [];
    for (const id of ids) {
      const entry = entryById.get(id);
      if (entry?.kind !== "entity") continue;
      if (await handleDecision(entry.item, decision)) {
        appliedIds.push(id);
      } else {
        failures.push({id, reason: "The decision was not recorded."});
      }
    }
    return {appliedIds, failures};
  };
  const undoToHold = async (ids: readonly string[]) => {
    await applyEntityDecision(ids, "hold");
  };
  const entityIds = entries
    .filter((entry) => entry.kind === "entity")
    .map((entry) => entry.id);
  return [
    {
      eligibleIds: entries
        .filter((entry) => entry.kind === "entity" && canApprove(
          entry.item,
          publicationPacketByEntity.get(entry.item.entityId),
          visibilityForms,
          surfaceChecklists,
          manualReportAcknowledgements
        ))
        .map((entry) => entry.id),
      id: "approve",
      label: "Approve",
      onApply: (ids) => applyEntityDecision(ids, "approve_public"),
      onUndo: undoToHold,
      tone: "success",
    },
    {
      eligibleIds: entityIds,
      id: "hold",
      label: "Hold",
      onApply: (ids) => applyEntityDecision(ids, "hold"),
    },
    {
      eligibleIds: entityIds,
      id: "suppress",
      label: "Suppress",
      onApply: (ids) => applyEntityDecision(ids, "suppress"),
      onUndo: undoToHold,
      tone: "danger",
    },
    {
      eligibleIds: entries
        .filter((entry) => entry.kind === "candidate" &&
          entry.candidate.existingEntityMatches.length > 0)
        .map((entry) => entry.id),
      id: "attach",
      label: "Attach",
      onApply: async (ids) => {
        const appliedIds: string[] = [];
        const failures: Array<{id: string; reason: string}> = [];
        for (const id of ids) {
          const entry = entryById.get(id);
          if (entry?.kind !== "candidate") continue;
          if (await handleAttachCandidate(entry.candidate)) appliedIds.push(id);
          else failures.push({id, reason: "The surface was not attached."});
        }
        return {appliedIds, failures};
      },
    },
  ];
}
