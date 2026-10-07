import assert from "node:assert/strict";
import test from "node:test";
import {hashValue} from "../../platform/canonical-json.mjs";
import {validateSalesResearchProposal} from "./research-proposal.mjs";
function fixture() {
  const text = "Synthetic Events runs monthly workshops. Registration uses Forms and WhatsApp.";
  const sources = [{sourceId: "official-page", url: "https://synthetic.example/events",
    capturedAt: "2026-10-04T00:00:00.000Z", text, contentHash: hashValue(text)}];
  const sourceHash = hashValue(sources);
  const proposal = {schemaVersion: 1, organizerId: "organizer-one", sourceHash,
    facts: [{claimKey: "recurrence", knowledgeStatus: "observed", value: "monthly workshops",
      excerpt: "runs monthly workshops", sourceIds: ["official-page"], rationale: "Literal public page text."},
    {claimKey: "operation", knowledgeStatus: "inferred", value: "Manual follow-up may be needed",
      excerpt: null, sourceIds: ["official-page"], rationale: "An inference requiring organizer confirmation."},
    {claimKey: "other", knowledgeStatus: "unknown", value: null, excerpt: null, sourceIds: [],
      rationale: "No private attendance or retention data was supplied."}],
    workflowComparison: {knowledgeStatus: "inferred",
      visibleTools: [{name: "Forms", sourceId: "official-page"}, {name: "WhatsApp", sourceId: "official-page"}],
      strongestPlausibleWorkflow: "Forms could collect applications and WhatsApp could coordinate participants; the organizer may already manage these steps well.",
      incrementalValue: "Ask whether a shared review workspace would reduce repeated coordination.",
      remainingQuestions: ["Which steps already work well?"]}};
  return {proposal, sources, organizerId: proposal.organizerId, sourceHash};
}
test("sourced observations, labeled inferences and unknowns remain private suggestions", () => {
  const result = validateSalesResearchProposal(fixture());
  assert.equal(result.verifiedEvidence, false);
  assert.equal(result.qualificationAuthority, false);
  assert.equal(result.sendAuthority, false);
});
test("observed facts cannot fabricate quoted content or source references", () => {
  for (const change of [(p) => {p.facts[0].excerpt = "Invented proof";},
    (p) => {p.facts[0].sourceIds = ["invented-source"];},
    (p) => {p.facts[2].value = "Unknown organizer attendance";}]) {
    const f = fixture(); change(f.proposal);
    assert.throws(() => validateSalesResearchProposal(f));
  }
});
test("visible-stack comparison cannot invent tool evidence or infer a baseline without visible tools", () => {
  const f = fixture(); f.proposal.workflowComparison.visibleTools[0].name = "Invented paid tool";
  assert.throws(() => validateSalesResearchProposal(f), {code: "SALES_RESEARCH_TOOL_UNGROUNDED"});
  const empty = fixture(); empty.proposal.workflowComparison.visibleTools = [];
  assert.throws(() => validateSalesResearchProposal(empty), {code: "SALES_RESEARCH_WORKFLOW_UNKNOWN"});
  empty.proposal.workflowComparison.knowledgeStatus = "unknown";
  assert.equal(validateSalesResearchProposal(empty).verifiedEvidence, false);
});
test("changed captured source or organizer rejects the frozen proposal", () => {
  const changed = fixture(); changed.sources[0].text += " Later correction";
  assert.throws(() => validateSalesResearchProposal(changed), {code: "SALES_RESEARCH_SOURCE_DRIFT"});
  const foreign = fixture(); foreign.organizerId = "organizer-two";
  assert.throws(() => validateSalesResearchProposal(foreign), {code: "SALES_RESEARCH_SOURCE_DRIFT"});
});
