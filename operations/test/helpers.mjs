import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";

export async function temporaryDirectory(prefix = "catch-operations-") {
  return fs.mkdtemp(path.join(os.tmpdir(), prefix));
}

export async function createFixtureRepository(root) {
  await writeJson(root, "tool/marketing/event_guide/generated/mumbai/2026-07-14/event_intake_bridge.json", {
    schemaVersion: 1,
    generatedAt: "2026-07-14T10:00:00.000Z",
    city: {id: "mumbai", label: "Mumbai"},
    weekStart: "2026-07-14",
    weekEnd: "2026-07-21",
    sourceProfiles: [
      {id: "legacy-web", label: "Legacy Web", type: "source_url_list", status: "needs_verification", items: []},
    ],
    sourceResults: [
      {
        id: "source-one",
        sourceProfileId: "legacy-web",
        sourceLabel: "Official site",
        title: "Official Event Result",
        url: "https://events.example/one",
        observedAt: "2026-07-14T00:00:00.000Z",
        status: "needs_review",
        riskFlags: [],
      },
    ],
    eventCandidates: [
      {
        id: "event-ready",
        title: "Ready Event",
        startDate: "2026-07-20",
        endDate: "2026-07-20",
        sourceUrl: "https://lu.ma/ready",
        sourceLabel: "Luma",
        sourceStatus: "source_attached",
        reviewState: "approved",
        requiresVerification: false,
        dedupe: {duplicateCandidateIds: []},
      },
      {
        id: "event-resolve",
        title: "Needs a source",
        startDate: "2026-07-21",
        endDate: "2026-07-21",
        sourceUrl: null,
        sourceStatus: "missing_source_url",
        reviewState: "new",
        requiresVerification: true,
        dedupe: {duplicateCandidateIds: []},
      },
      {
        id: "event-expired",
        title: "Expired Event",
        startDate: "2026-07-01",
        endDate: "2026-07-01",
        sourceUrl: "https://events.example/expired",
        sourceStatus: "source_attached",
        reviewState: "approved",
        requiresVerification: false,
        dedupe: {duplicateCandidateIds: []},
      },
    ],
  });
  await writeJson(root, "tool/organizer_intake/generated/publication_review_packets.json", {
    schemaVersion: 1,
    packets: [{
      entityId: "organizer-ready",
      canonicalHostId: "organizer-ready",
      displayName: "Ready Organizer",
      identity: {
        geography: {
          primaryMarketSlug: "mumbai",
          markets: [{marketSlug: "mumbai", eventFilter: {citySlug: "mumbai"}}],
        },
      },
      blockers: [],
      dataBlockers: [],
      evidenceBlockers: [],
      evidenceReview: {manualReportsWithoutArtifacts: 0, records: []},
      adminDecision: {currentDecision: {decision: "approve_public"}},
    }],
  });
  await writeJson(root, "tool/organizer_intake/generated/organizer_operator_action_queue.json", {schemaVersion: 1, actions: []});
  await writeJson(root, "tool/organizer_intake/generated/organizer_operational_health.json", {schemaVersion: 1, summary: {workstreams: 0}});
  await writeJson(root, "tool/organizer_intake/generated/source_mention_llm_prompt_queue.json", {schemaVersion: 1, requests: []});
  await writeJson(root, "tool/organizer_intake/generated/event_crawl_run_plan.json", {schemaVersion: 1, runIntents: []});
  return root;
}

async function writeJson(root, relative, value) {
  const file = path.join(root, relative);
  await fs.mkdir(path.dirname(file), {recursive: true});
  await fs.writeFile(file, `${JSON.stringify(value, null, 2)}\n`);
}
