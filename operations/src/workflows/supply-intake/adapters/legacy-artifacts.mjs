import fs from "node:fs/promises";
import path from "node:path";
import {hashText} from "../../../platform/canonical-json.mjs";
import {OperationsError, invariant} from "../../../platform/errors.mjs";

export const LEGACY_ARTIFACTS = Object.freeze({
  organizerPublicationPackets: "tool/organizer_intake/generated/publication_review_packets.json",
  organizerActionQueue: "tool/organizer_intake/generated/organizer_operator_action_queue.json",
  organizerHealth: "tool/organizer_intake/generated/organizer_operational_health.json",
  llmPromptQueue: "tool/organizer_intake/generated/source_mention_llm_prompt_queue.json",
  crawlRunPlan: "tool/organizer_intake/generated/event_crawl_run_plan.json",
});

export const LEGACY_ARTIFACT_PATTERNS = Object.freeze([
  "tool/marketing/event_guide/generated/{market}/{reviewedRun}/event_intake_bridge.json",
  ...Object.values(LEGACY_ARTIFACTS),
]);

export class LegacyIntakeArtifactAdapter {
  constructor({repoRoot}) {
    invariant(typeof repoRoot === "string" && repoRoot.length > 0, "INVALID_ADAPTER", "Repository root is required.");
    this.repoRoot = path.resolve(repoRoot);
  }

  async snapshot({market}) {
    const eventBridgePath = await this.latestEventBridgePath(market);
    const entries = await Promise.all([
      this.readArtifact("eventIntakeBridge", eventBridgePath),
      ...Object.entries(LEGACY_ARTIFACTS).map(([id, relativePath]) => this.readArtifact(id, relativePath)),
    ]);
    return {
      schemaVersion: 1,
      adapterId: "legacy-intake-artifacts-v1",
      artifacts: Object.fromEntries(entries.map((entry) => [entry.id, entry])),
    };
  }

  async latestEventBridgePath(market) {
    const root = this.resolve(`tool/marketing/event_guide/generated/${market}`);
    let entries;
    try {
      entries = await fs.readdir(root, {withFileTypes: true});
    } catch (error) {
      if (error?.code === "ENOENT") {
        throw new OperationsError("ARTIFACT_NOT_FOUND", `No Event Intake bridge directory exists for ${market}.`, {
          details: {market, expectedRoot: relativeTo(this.repoRoot, root)},
          exitCode: 2,
        });
      }
      throw error;
    }
    const candidates = entries
      .filter((entry) => entry.isDirectory())
      .map((entry) => `tool/marketing/event_guide/generated/${market}/${entry.name}/event_intake_bridge.json`)
      .sort()
      .reverse();
    for (const candidate of candidates) {
      try {
        await fs.access(this.resolve(candidate));
        return candidate;
      } catch {
        // Continue to the next older reviewed bridge.
      }
    }
    throw new OperationsError("ARTIFACT_NOT_FOUND", `No Event Intake bridge exists for ${market}.`, {
      details: {market, candidates},
      exitCode: 2,
    });
  }

  async readArtifact(id, relativePath) {
    const absolutePath = this.resolve(relativePath);
    try {
      const text = await fs.readFile(absolutePath, "utf8");
      return {
        id,
        status: "available",
        relativePath: relativeTo(this.repoRoot, absolutePath),
        sha256: hashText(text),
        sizeBytes: Buffer.byteLength(text, "utf8"),
        data: JSON.parse(text),
      };
    } catch (error) {
      if (error?.code === "ENOENT") {
        return {id, status: "missing", relativePath, sha256: null, sizeBytes: 0, data: null};
      }
      if (error instanceof SyntaxError) {
        throw new OperationsError("ARTIFACT_INVALID", `Legacy artifact ${relativePath} is invalid JSON.`, {cause: error});
      }
      throw error;
    }
  }

  async reload(snapshot) {
    const entries = await Promise.all(Object.values(snapshot.artifacts).map((artifact) =>
      this.readArtifact(artifact.id, artifact.relativePath)
    ));
    for (const entry of entries) {
      const planned = snapshot.artifacts[entry.id];
      if (planned.status !== entry.status || planned.sha256 !== entry.sha256) {
        throw new OperationsError("ARTIFACT_DRIFT", `Legacy artifact ${entry.relativePath} changed after planning.`, {
          details: {id: entry.id, plannedHash: planned.sha256, actualHash: entry.sha256},
          exitCode: 6,
        });
      }
    }
    return Object.fromEntries(entries.map((entry) => [entry.id, entry]));
  }

  resolve(relativePath) {
    const resolved = path.resolve(this.repoRoot, relativePath);
    const relative = path.relative(this.repoRoot, resolved);
    invariant(relative === "" || (!relative.startsWith("..") && !path.isAbsolute(relative)), "PATH_ESCAPE", "Legacy artifact path escapes repository root.");
    return resolved;
  }
}

export function stripArtifactData(snapshot) {
  return {
    ...snapshot,
    artifacts: Object.fromEntries(Object.entries(snapshot.artifacts).map(([id, artifact]) => [id, {
      id: artifact.id,
      status: artifact.status,
      relativePath: artifact.relativePath,
      sha256: artifact.sha256,
      sizeBytes: artifact.sizeBytes,
      counts: artifactCounts(id, artifact.data),
    }])),
  };
}

function artifactCounts(id, data) {
  if (!data) return {};
  if (id === "eventIntakeBridge") return {
    sourceProfiles: data.sourceProfiles?.length ?? 0,
    sourceResults: data.sourceResults?.length ?? 0,
    eventCandidates: data.eventCandidates?.length ?? 0,
  };
  if (id === "organizerPublicationPackets") return {organizers: data.packets?.length ?? 0};
  if (id === "organizerActionQueue") return {actions: data.actions?.length ?? 0};
  if (id === "llmPromptQueue") return {requests: data.requests?.length ?? 0};
  if (id === "crawlRunPlan") return {runIntents: data.runIntents?.length ?? 0};
  return data.summary ?? {};
}

function relativeTo(root, file) {
  return path.relative(root, file).split(path.sep).join("/");
}
