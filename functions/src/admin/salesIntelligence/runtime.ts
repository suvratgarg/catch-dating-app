/* eslint-disable max-len */
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import {pathToFileURL} from "node:url";
import type {SalesPrincipal} from "../sales/types";
import {fail} from "./model";
import {claimDraftJob, completeDraftJob,
  type DraftJob} from "./job";
import {buildOutreachInput, recordOperationsDraft,
  type IntelligenceDeps} from "./service";

interface PackagedOperations {
  FileOperationsStore: new (root: string) => {initialize: () => Promise<unknown>};
  createSalesOutreachRunner: (options: Record<string, unknown>) => {
    run: (input: Record<string, unknown>) => Promise<{
      draft: {draftId: string; draft: {contentHash: string}}}>};
}

async function packagedOperations(): Promise<PackagedOperations> {
  const root = path.resolve(__dirname, "../..");
  const adapter = path.join(root, "operations", "src", "workflows",
    "outreach-drafting", "sales-adapter.mjs");
  const store = path.join(root, "operations", "src", "platform",
    "storage", "file-store.mjs");
  try {
    const [adapterModule, storeModule] = await Promise.all([
      import(pathToFileURL(adapter).href),
      import(pathToFileURL(store).href),
    ]);
    return {createSalesOutreachRunner: adapterModule.createSalesOutreachRunner,
      FileOperationsStore: storeModule.FileOperationsStore};
  } catch {
    return fail("failed-precondition",
      "The reviewed outreach runtime is not packaged for this environment.");
  }
}

/** Zero-model synchronous callable path; scratch is never authority. */
export async function generateSalesOutreachDraft(deps: IntelligenceDeps,
  principal: SalesPrincipal, payload: unknown): Promise<Record<string, unknown>> {
  const claimed = await claimDraftJob(deps, principal, payload);
  if (!claimed.claimed) {
    if (claimed.job.status === "failed") {
      return {status: "failed", failure: claimed.job.failure};
    }
    if (claimed.job.status === "completed") {
      return {status: "completed", result: claimed.job.result,
        idempotentReplay: true};
    }
    return {status: "running", retryAfterSeconds: 5};
  }
  const job: DraftJob = claimed.job;
  const scratch = await fs.mkdtemp(path.join(os.tmpdir(),
    "catch-outreach-zero-model-"));
  try {
    const {FileOperationsStore, createSalesOutreachRunner} =
      await packagedOperations();
    const store = await new FileOperationsStore(scratch).initialize();
    const runner = createSalesOutreachRunner({store,
      source: {
        prepare: async (actor: SalesPrincipal) => {
          if (actor.uid !== principal.uid) {
            return fail("permission-denied", "Draft actor changed.");
          }
          await deps.authorize(principal, false);
          return {bundle: job.frozenBundle, sourceHash: job.sourceHash};
        },
        current: async (actor: SalesPrincipal) => {
          if (actor.uid !== principal.uid) {
            return fail("permission-denied", "Draft actor changed.");
          }
          return buildOutreachInput(deps, principal, job.sourceRequest);
        },
      },
      save: async ({actor, requestId, sourceRequest, frozenBundle,
        frozenSourceHash, rendered}: {
        actor: SalesPrincipal; requestId: string;
        sourceRequest: DraftJob["sourceRequest"];
        frozenBundle: Record<string, unknown>;
        frozenSourceHash: string; rendered: unknown;
      }) => {
        if (actor.uid !== principal.uid) {
          return fail("permission-denied", "Draft actor changed.");
        }
        return recordOperationsDraft(deps, principal, requestId,
          sourceRequest, frozenBundle, frozenSourceHash, rendered);
      },
      clock: deps.now,
      workerId: `sales-${job.jobId}`});
    const result = await runner.run({requestId: job.requestId,
      actor: principal, sourceRequest: job.sourceRequest});
    const completed = await completeDraftJob(deps, principal, job, result.draft);
    return {status: "completed", result: completed.result,
      idempotentReplay: false};
  } catch (error) {
    // A draft may already have been committed when a later operation fails.
    // Keep the lease retryable so the same request can recover its receipt.
    if (error instanceof Error && "code" in error &&
        typeof error.code === "string" &&
        ["permission-denied", "aborted", "failed-precondition",
          "resource-exhausted"].includes(error.code)) {
      throw error;
    }
    return fail("failed-precondition",
      "Draft generation stopped before an approved result was saved.");
  } finally {
    await fs.rm(scratch, {recursive: true, force: true});
  }
}
