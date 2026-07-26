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
    packets: [publicationPacketFixture({
      entityId: "organizer-ready",
      market: "mumbai",
      status: "published",
    })],
  });
  await writeJson(root, "tool/organizer_intake/generated/search_result_candidate_queue.json", {
    schemaVersion: 1,
    candidates: [],
    summary: {candidates: 0},
  });
  await writeJson(root, "tool/organizer_intake/generated/organizer_operator_action_queue.json", {schemaVersion: 1, actions: []});
  await writeJson(root, "tool/organizer_intake/generated/organizer_operational_health.json", {schemaVersion: 1, summary: {workstreams: 0}});
  await writeJson(root, "tool/organizer_intake/generated/source_mention_llm_prompt_queue.json", {schemaVersion: 1, requests: []});
  await writeJson(root, "tool/organizer_intake/generated/event_crawl_run_plan.json", {schemaVersion: 1, runIntents: []});
  return root;
}

export function publicationPacketFixture({
  entityId,
  market,
  status = "ready_for_manual_publication_review",
}) {
  return {
    packetId: `packet-${entityId}`,
    entityId,
    canonicalHostId: entityId,
    displayName: `${market} Organizer`,
    status,
    priority: "p1",
    blockers: [],
    dataBlockers: [],
    evidenceBlockers: [],
    approvalChecklist: {
      crawlDisabledReviewed: true,
      identityReviewed: true,
      marketScopeReviewed: true,
      mediaRightsReviewed: true,
      ownerSafeCopyReviewed: true,
      surfaceInventoryReviewed: true,
    },
    evidenceSummary: {
      records: 2,
      manualReportsWithoutArtifacts: 0,
      unresolvedLocalRefs: 0,
      missingSurfaceEvidence: 0,
      rawProviderArtifactRefs: 0,
      firestoreForbiddenArtifactRefs: 0,
      riskFlags: [],
    },
    evidenceReview: {manualReportsWithoutArtifacts: 0, records: []},
    identity: {
      geography: {
        primaryMarketSlug: market,
        markets: [{
          marketSlug: market,
          displayName: market,
          eventFilter: {citySlug: market},
        }],
      },
    },
    publicPresence: {
      canonicalPath: `/organizers/${entityId}/`,
      claimTargetPath: `clubs/${entityId}`,
      indexStatus: status === "published" ? "indexed" : "noindex",
      appVisibility: "hidden",
      projectionStatus: "ready",
    },
    adminDecision: {
      allowedDecisions: ["approve_public", "hold", "suppress"],
      defaultAppVisibility: "hidden",
      currentDecision: status === "published" ? {
        decision: "approve_public",
        decidedAt: "2026-07-14",
        appVisibility: "hidden",
      } : null,
      command: "must-not-reach-admin-projection",
    },
    nextActions: ["review_publication_packet"],
  };
}

async function writeJson(root, relative, value) {
  const file = path.join(root, relative);
  await fs.mkdir(path.dirname(file), {recursive: true});
  await fs.writeFile(file, `${JSON.stringify(value, null, 2)}\n`);
}
