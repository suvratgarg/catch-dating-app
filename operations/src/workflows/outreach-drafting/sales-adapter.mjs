import {OperationsEngine} from "../../platform/engine.mjs";
import {OutreachDraftingWorkflow} from "./workflow.mjs";

/**
 * Connects the trusted Sales bundle and current-source ports to the existing
 * zero-model Operations workflow. No source text or provider output is prose.
 * The caller supplies a durable Operations store and a transactional Sales
 * persistence hook; FileOperationsStore is suitable only for local review.
 */
export function createSalesOutreachRunner({store, source, save, clock = () => new Date(),
  workerId = "sales-outreach"}) {
  if (!store?.createRun || !source?.prepare || !source?.current || !save) {
    throw new TypeError("Durable store, trusted Sales source and persistence hook required.");
  }
  return {
    async run({requestId, actor, sourceRequest}) {
      const prepared = await source.prepare(actor, sourceRequest);
      const input = structuredClone(prepared.bundle);
      const eligibilityPort = {getCurrent: async ({organizerId, contactId,
        opportunityId}) => {
        if (organizerId !== input.organizer.organizerId ||
            contactId !== input.contact.contactId ||
            opportunityId !== input.opportunity.opportunityId) {
          throw new Error("Sales target changed during current-source check.");
        }
        const fresh = await source.current(actor, sourceRequest);
        if (fresh.sourceHash !== prepared.sourceHash) {
          throw new Error("Sales evidence or contact source changed during drafting.");
        }
        return currentProjection(fresh.bundle);
      }};
      const workflow = new OutreachDraftingWorkflow({store, eligibilityPort,
        modelActivation: null, modelProvider: null,
        clock: () => new Date(input.evaluatedAt)});
      const engine = new OperationsEngine({store, workflow,
        clock: () => new Date(input.evaluatedAt),
        leaseClock: clock, workerId});
      const plan = workflow.createPlan({inputs: [input], now: input.evaluatedAt});
      if (plan.budgets.modelCalls !== 0 || plan.capabilities.modelCalls !== false ||
          plan.capabilities.network !== false || plan.capabilities.publicWrites !== false) {
        throw new Error("Zero-model private drafting plan required.");
      }
      const result = await engine.start(plan);
      const items = await store.listWorkItems({runId: result.run.runId});
      if (items.length !== 1 || items[0].primaryStage !== "human_review" ||
          !items[0].decisionProvenance?.draft) {
        throw new Error("Operations draft did not reach human review.");
      }
      const draft = items[0].decisionProvenance.draft;
      // This hook re-reads every Sales source within its own write transaction.
      const stored = await save({actor, requestId, sourceRequest,
        frozenBundle: input, frozenSourceHash: prepared.sourceHash,
        rendered: draft});
      return {runId: result.run.runId, workItemId: items[0].workItemId,
        draft: stored, idempotentReplay: result.idempotentReplay === true,
        sendAuthority: false};
    },
  };
}

export function currentProjection(bundle) {
  const clauses = [...bundle.observations, ...bundle.capabilities,
    ...bundle.references];
  return {organizerId: bundle.organizer.organizerId,
    organizerRevision: bundle.organizer.revision,
    contactId: bundle.contact.contactId,
    contactRevision: bundle.contact.revision,
    opportunityId: bundle.opportunity.opportunityId,
    opportunityRevision: bundle.opportunity.revision,
    stage: bundle.opportunity.stage,
    identityStatus: bundle.organizer.identityStatus,
    contactEligible: bundle.contact.eligibility === "eligible",
    suppressed: bundle.contact.suppressionStatus !== "clear",
    capabilityClaimsEligible: bundle.capabilities.length > 0,
    evidenceConflictStatus: bundle.evidenceConflictStatus,
    promptVersion: bundle.policy.promptVersion,
    playbookVersion: bundle.policy.playbookVersion,
    approvedClauseRevisions: Object.fromEntries(clauses.map(
      (row) => [row.id, row.revision])),
    supportedCapabilityIds: bundle.capabilities.map((row) => row.id),
    permittedReferenceIds: bundle.references.map((row) => row.id),
    approvedCtaRevisions: Object.fromEntries(bundle.ctas.map(
      (row) => [row.id, row.revision])),
    priorInteractionRevision: bundle.priorInteraction?.revision ?? null};
}
