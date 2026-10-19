import {describe, expect, it} from "vitest";
import * as marketing from "./marketing";

// These fields are identifiers or destinations, not words rendered to visitors.
const machineFields = new Set(["id", "token", "activityToken", "href", "captureId"]);
const bannedSystemWording = /\b(?:aggregate[-\s]+safe|claim[-\s]+state|source[-\s]+ledger|projections?|mechanics?)\b/iu;

function publicProse(value: unknown, path = "marketing"): Array<{path: string; text: string}> {
  if (typeof value === "string") return [{path, text: value}];
  if (Array.isArray(value)) {
    return value.flatMap((item, index) => publicProse(item, `${path}[${index}]`));
  }
  if (value && typeof value === "object") {
    return Object.entries(value).flatMap(([key, item]) =>
      machineFields.has(key) ? [] : publicProse(item, `${path}.${key}`)
    );
  }
  return [];
}

function bannedPublicProse(value: unknown): string[] {
  return publicProse(value)
    .filter(({text}) => bannedSystemWording.test(text))
    .map(({path, text}) => `${path}: ${text}`);
}

describe("public marketing wording", () => {
  it("rejects banned system phrases in visitor-facing copy, including a seeded regression", () => {
    expect(bannedPublicProse({body: "Host reports stay aggregate-safe."})).toEqual([
      "marketing.body: Host reports stay aggregate-safe.",
    ]);
    expect(bannedPublicProse({facts: ["A SOURCE LEDGER is shown."]})).toEqual([
      "marketing.facts[0]: A SOURCE LEDGER is shown.",
    ]);
    expect(bannedPublicProse({id: "aggregate-safe", body: "Hosts see totals."})).toEqual([]);
    expect(bannedPublicProse(marketing)).toEqual([]);
  });

  it("explains privacy in reports and assignments without changing their purpose", () => {
    const privateTrust = marketing.trustItems.find(({title}) => title === "Private by default");
    expect(privateTrust?.body).toMatch(/Catches are private unless mutual/u);
    expect(privateTrust?.body).toMatch(/reports show totals, never who caught whom/u);

    const assignments = marketing.hostModules.find(({title}) => title === "Assignments");
    expect(assignments?.body).toMatch(/pairs, tables, pods, teams, and rotations/u);
    expect(assignments?.body).toMatch(/adjust assignments without seeing guests' private catches/u);

    const reporting = marketing.hostFillRoomModules.find(({id}) => id === "balanced-cohorts")?.facts.join(" ");
    expect(reporting).toMatch(/Before, during, and after the event/u);
    expect(reporting).toMatch(/overall numbers without revealing guests' private choices/u);
  });
});
