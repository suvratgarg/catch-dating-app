import {createHash} from "node:crypto";
import {HttpsError} from "firebase-functions/v2/https";
import {dutyAssignments, dutyCoversHotel, requireProgramAccess,
  requireProgramDuty, requireProgramMutable} from "../shared/programAuthority";
import type {ProgramAccess} from "../shared/programAuthority";
import type {ProgramDataDeps} from "../shared/programDataDeps";
import {assertLodgingProposalCurrent, immutableLodgingProposal,
  lodgingProposalId, planLodging}
  from "./programLodgingPlanner";
import {lodgingHotelProjection, lodgingTransition}
  from "./programLodgingTransitions";
import type {LodgingAuthority, LodgingCommand, LodgingReceipt, LodgingWorkflow}
  from "./programLodgingTransitions";
import {validateLodgingPlacements} from "./programLodgingValidation";
import type {LodgingProposal, LodgingSnapshot} from "./programLodgingTypes";

export interface TransactionLodgingSource {
  snapshot: LodgingSnapshot;
  /** Prepared using reads in loadSource. This callback may only enqueue
   * canonical stay/occupancy writes in this same transaction, with no IO.
   * It must increment the published-source revision and preserve check-ins. */
  publish: (proposal: LodgingProposal) => void;
}
export type LoadLodgingSource = (
  transaction: FirebaseFirestore.Transaction,
  access: ProgramAccess,
  programId: string,
) => Promise<TransactionLodgingSource>;
interface StoredProposal {
  programId: string;
  organizerId: string;
  proposal: LodgingProposal;
  createdByUid: string;
  createdAtMillis: number;
}
interface StoredWorkflow {
  programId: string;
  organizerId: string;
  workflow: LodgingWorkflow;
}
interface StoredReceipt {
  programId: string;
  organizerId: string;
  receipt: LodgingReceipt;
}
const emptyWorkflow = (): LodgingWorkflow => ({revision: 0,
  approvedProposalId: null, confirmedHotelIds: [],
  guestPublishedProposalId: null});

/** Server-only transactional adapter. Callables must derive actorUid from
 * requireAuth, never from payloads. No exported callable exists until authored
 * contracts, the canonical source/publication bridge and readers are wired. */
export class ProgramLodgingStore {
  constructor(private readonly deps: ProgramDataDeps,
    private readonly loadSource: LoadLodgingSource) {}

  async preview(programId: string, actorUid: string): Promise<LodgingProposal> {
    const snapshot = await this.deps.firestore().runTransaction(async (tx) => {
      const access = await this.access(tx, programId, actorUid);
      requireProgramDuty(access, "programCoordinator");
      const source = await this.loadSource(tx, access, programId);
      this.assertScope(source.snapshot, access, programId);
      this.authority(access, actorUid, source.snapshot);
      return source.snapshot;
    });
    // Search outside the transaction. Save revalidates current authority and
    // every source revision; generating a proposal does not reserve a room.
    return planLodging(snapshot);
  }

  async save(programId: string, actorUid: string,
    proposal: LodgingProposal): Promise<LodgingProposal> {
    return this.deps.firestore().runTransaction(async (tx) => {
      const access = await this.access(tx, programId, actorUid);
      requireProgramDuty(access, "programCoordinator");
      const {snapshot} = await this.loadSource(tx, access, programId);
      this.assertScope(snapshot, access, programId);
      this.authority(access, actorUid, snapshot);
      assertLodgingProposalCurrent(proposal, snapshot.revisions);
      if (proposal.scope.programId !== programId ||
          proposal.scope.organizerId !== access.program.organizerId ||
          proposal.placements.length > snapshot.parties.length) {
        throw new HttpsError("failed-precondition", "Invalid lodging scope.");
      }
      const canonical = immutableLodgingProposal(snapshot, proposal.placements);
      if (canonical.id !== proposal.id) {
        throw new HttpsError("failed-precondition",
          "Proposal identity changed.");
      }
      const ref = this.proposalRef(canonical.id);
      const existing = await tx.get(ref);
      // Reads can cross a duty expiry, including an idempotent save replay.
      this.authority(access, actorUid, snapshot);
      if (existing.exists) {
        const stored = existing.data() as StoredProposal;
        this.assertStoredProposal(stored, access, programId, canonical.id);
        return stored.proposal;
      }
      tx.create(ref, {programId, organizerId: access.program.organizerId,
        proposal: canonical, createdByUid: actorUid,
        createdAtMillis: this.deps.now().toMillis()} satisfies StoredProposal);
      return canonical;
    });
  }

  async transition(programId: string, actorUid: string,
    command: LodgingCommand) {
    return this.deps.firestore().runTransaction(async (tx) => {
      const access = await this.access(tx, programId, actorUid);
      const source = await this.loadSource(tx, access, programId);
      this.assertScope(source.snapshot, access, programId);
      const workflowRef = this.deps.firestore()
        .collection("programLodgingWorkflows").doc(programId);
      const receiptId = createHash("sha256").update(JSON.stringify([
        programId, actorUid, command.operationId,
      ])).digest("hex");
      const receiptRef = this.deps.firestore()
        .collection("programLodgingReceipts").doc(receiptId);
      const [proposalSnap, workflowSnap, receiptSnap] = await tx.getAll(
        this.proposalRef(command.proposalId), workflowRef, receiptRef);
      if (!proposalSnap.exists) {
        throw new HttpsError("not-found", "No proposal.");
      }
      const storedProposal = proposalSnap.data() as StoredProposal;
      this.assertStoredProposal(storedProposal, access, programId,
        command.proposalId);
      const storedWorkflow = workflowSnap.data() as StoredWorkflow | undefined;
      const storedReceipt = receiptSnap.data() as StoredReceipt | undefined;
      if (storedWorkflow) {
        this.assertStoredScope(storedWorkflow, access, programId);
      }
      if (storedReceipt) {
        this.assertStoredScope(storedReceipt, access, programId);
      }
      const workflow = storedWorkflow?.workflow ?? emptyWorkflow();
      const currentSnapshot = command.action === "confirmHotel" ?
        this.approvedSnapshot(source.snapshot,
          storedProposal.proposal, workflow) :
        source.snapshot;
      const result = lodgingTransition(currentSnapshot, storedProposal.proposal,
        workflow,
        this.authority(access, actorUid, source.snapshot, command.hotelId),
        command, storedReceipt?.receipt ?? null, this.deps.now().toMillis());
      if (!result.replayed) {
        if (command.action === "publishGuests") {
          source.publish(storedProposal.proposal);
        }
        tx.set(workflowRef, {programId, organizerId: access.program.organizerId,
          workflow: result.workflow} satisfies StoredWorkflow);
        tx.create(receiptRef, {programId,
          organizerId: access.program.organizerId,
          receipt: result.receipt} satisfies StoredReceipt);
      }
      return result;
    });
  }

  async hotelBoard(programId: string, actorUid: string, hotelId: string) {
    return this.deps.firestore().runTransaction(async (tx) => {
      const access = await this.access(tx, programId, actorUid, false);
      const {snapshot} = await this.loadSource(tx, access, programId);
      this.assertScope(snapshot, access, programId);
      const authority = this.authority(access, actorUid, snapshot, hotelId);
      const state = await tx.get(this.deps.firestore()
        .collection("programLodgingWorkflows").doc(programId));
      if (!state.exists) return [];
      const stored = state.data() as StoredWorkflow;
      this.assertStoredScope(stored, access, programId);
      if (!stored.workflow.approvedProposalId) return [];
      const proposalSnap = await tx.get(this.proposalRef(
        stored.workflow.approvedProposalId));
      if (!proposalSnap.exists) {
        throw new HttpsError("not-found", "No proposal.");
      }
      const proposal = proposalSnap.data() as StoredProposal;
      this.assertStoredProposal(proposal, access, programId,
        stored.workflow.approvedProposalId);
      const approved = this.approvedSnapshot(snapshot,
        proposal.proposal, stored.workflow);
      if (validateLodgingPlacements(approved,
        proposal.proposal.placements, true).length) {
        throw new HttpsError("failed-precondition",
          "Approved lodging proposal must be complete and feasible.");
      }
      return lodgingHotelProjection(approved, proposal.proposal, authority,
        hotelId, this.deps.now().toMillis());
    });
  }

  private assertStoredProposal(stored: StoredProposal, access: ProgramAccess,
    programId: string, expectedId: string) {
    this.assertStoredScope(stored, access, programId);
    const proposal = stored.proposal;
    try {
      if (proposal.scope.programId !== programId ||
          proposal.scope.organizerId !== access.program.organizerId ||
          proposal.id !== expectedId ||
          lodgingProposalId(proposal.scope, proposal.revisions,
            proposal.placements) !== expectedId) {
        throw new Error("Invalid proposal identity");
      }
    } catch {
      throw new HttpsError("failed-precondition",
        "Saved lodging proposal content does not match its identity.");
    }
  }

  private approvedSnapshot(snapshot: LodgingSnapshot,
    proposal: LodgingProposal, workflow: LodgingWorkflow): LodgingSnapshot {
    // Publication advances its own source revision. Accept precisely that
    // revision for subsequent hotel confirmation/preview, only while the
    // canonical published allocation still equals this immutable proposal.
    const keys = (rows: ReadonlyArray<{
      partyId: string; inventoryId: string;
    }>) =>
      JSON.stringify(rows.map((r) => [r.partyId, r.inventoryId]).sort());
    if (workflow.guestPublishedProposalId === proposal.id &&
        snapshot.revisions.published === proposal.revisions.published + 1 &&
        keys(snapshot.published) === keys(proposal.placements)) {
      return {...snapshot, revisions: {...snapshot.revisions,
        published: proposal.revisions.published}};
    }
    return snapshot;
  }

  private proposalRef(id: string) {
    if (!/^[a-f0-9]{64}$/.test(id)) {
      throw new HttpsError("invalid-argument", "Invalid proposal ID.");
    }
    return this.deps.firestore().collection("programLodgingProposals").doc(id);
  }
  private async access(tx: FirebaseFirestore.Transaction, programId: string,
    actorUid: string, mutable = true) {
    const access = await requireProgramAccess({db: this.deps.firestore(),
      programId, actorUid, now: this.deps.now(), transaction: tx});
    if (mutable) requireProgramMutable(access.program);
    return access;
  }
  private assertScope(snapshot: LodgingSnapshot, access: ProgramAccess,
    programId: string) {
    this.assertStoredScope({programId: snapshot.scope.programId,
      organizerId: snapshot.scope.organizerId}, access, programId);
  }
  private assertStoredScope(stored: {programId: string; organizerId: string},
    access: ProgramAccess, programId: string) {
    if (stored.programId !== programId ||
        stored.organizerId !== access.program.organizerId) {
      throw new HttpsError("permission-denied", "Foreign lodging data.");
    }
  }
  private authority(access: ProgramAccess, actorUid: string,
    snapshot: LodgingSnapshot,
    hotelId: string | null = null): LodgingAuthority {
    const base = {uid: actorUid, ...snapshot.scope, hotelIds: [] as string[]};
    if (access.role === "manager") {
      return {...base, role: "manager",
        expiresAtMillis: Number.MAX_SAFE_INTEGER};
    }
    const coordinators = dutyAssignments(access, "programCoordinator");
    if (coordinators.length) {
      const expiry = Math.max(...coordinators.map((d) => d.expiresAtMillis));
      if (expiry <= this.deps.now().toMillis()) {
        throw new HttpsError("permission-denied", "Lodging duty expired.");
      }
      return {...base, role: "coordinator", expiresAtMillis: expiry};
    }
    const desks = dutyAssignments(access, "hotelDesk").filter((d) =>
      d.expiresAtMillis > this.deps.now().toMillis() &&
      hotelId !== null && dutyCoversHotel([d], hotelId));
    if (!hotelId || !desks.length) {
      throw new HttpsError("permission-denied", "Hotel duty required.");
    }
    return {...base, role: "hotelDesk", hotelIds: [hotelId],
      expiresAtMillis: Math.max(...desks.map((d) => d.expiresAtMillis))};
  }
}
