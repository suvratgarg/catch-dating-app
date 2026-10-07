import fs from "node:fs";
import {hashValue} from "../../platform/canonical-json.mjs";
import {invariant} from "../../platform/errors.mjs";
import {validateJsonSchema} from "../../platform/json-schema.mjs";
const schema = JSON.parse(fs.readFileSync(new URL(
  "../../../../contracts/operations/sales_research_proposal.schema.json", import.meta.url), "utf8"));

/** Validated suggestion for existing Sales review, never verified evidence. */
export function validateSalesResearchProposal({proposal, sources, organizerId, sourceHash}) {
  const checked = validateJsonSchema(schema, proposal);
  invariant(checked.valid, "SALES_RESEARCH_PROPOSAL_INVALID", "Research output must remain a bounded sourced proposal.",
    {errors: checked.errors});
  invariant(Array.isArray(sources) && sources.length <= 50 &&
    Buffer.byteLength(JSON.stringify(sources), "utf8") <= 500000,
  "SALES_RESEARCH_SOURCES_INVALID", "Bounded captured sources are required.");
  invariant(proposal.organizerId === organizerId && proposal.sourceHash === sourceHash &&
    hashValue(sources) === sourceHash, "SALES_RESEARCH_SOURCE_DRIFT", "Proposal source snapshot changed.");
  const registry = new Map();
  for (const source of sources) {
    invariant(typeof source.sourceId === "string" && !registry.has(source.sourceId) &&
      typeof source.text === "string" && Buffer.byteLength(source.text, "utf8") <= 100000 &&
      source.contentHash === hashValue(source.text) && Number.isFinite(Date.parse(source.capturedAt)),
    "SALES_RESEARCH_SOURCES_INVALID", "Each captured source needs unique identity, content hash and observation time.");
    const url = new URL(source.url);
    invariant(url.protocol === "https:" && !url.username && !url.password,
      "SALES_RESEARCH_SOURCES_INVALID", "Captured sources must identify an HTTPS page.");
    registry.set(source.sourceId, source);
  }
  for (const fact of proposal.facts) {
    const referenced = fact.sourceIds.map((id) => registry.get(id));
    invariant(referenced.every(Boolean), "SALES_RESEARCH_SOURCE_UNKNOWN", "A proposal cannot invent source references.");
    if (fact.knowledgeStatus === "unknown") {
      invariant(fact.value === null && fact.excerpt === null,
        "SALES_RESEARCH_UNKNOWN_FACT", "Unknown facts cannot assert a value or proof.");
    } else {
      invariant(referenced.length > 0, "SALES_RESEARCH_SOURCE_REQUIRED", "Observed and inferred facts require captured sources.");
      if (fact.knowledgeStatus === "observed") {
        invariant(typeof fact.excerpt === "string" && typeof fact.value === "string" &&
          referenced.some((source) => source.text.includes(fact.excerpt)) &&
          fact.excerpt.includes(fact.value), "SALES_RESEARCH_OBSERVATION_UNGROUNDED",
        "Observed facts must be literal content from a captured source; interpretation remains inferred.");
      }
    }
  }
  for (const tool of proposal.workflowComparison.visibleTools) {
    const source = registry.get(tool.sourceId);
    invariant(source?.text.includes(tool.name), "SALES_RESEARCH_TOOL_UNGROUNDED",
      "The strongest plausible workflow can use only visibly sourced tools.");
  }
  invariant(proposal.workflowComparison.visibleTools.length > 0 ||
    proposal.workflowComparison.knowledgeStatus === "unknown",
  "SALES_RESEARCH_WORKFLOW_UNKNOWN", "Without visible tools, the baseline workflow remains unknown.");
  return {proposal: structuredClone(proposal), proposalHash: hashValue(proposal),
    verifiedEvidence: false, qualificationAuthority: false, sendAuthority: false};
}
