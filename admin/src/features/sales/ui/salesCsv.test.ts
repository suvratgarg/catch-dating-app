import {describe, expect, it} from "vitest";
import {parseSalesCsv, salesImportPacket} from "./salesCsv";

describe("Sales CSV import mapping", () => {
  it("parses quoted commas, newlines, escaped quotes, and a BOM", () => {
    expect(parseSalesCsv("\uFEFFname,status,summary\r\n" +
      '"Host, North",needs_research,"Line one\nLine ""two"""\r\n'))
      .toEqual([["name", "status", "summary"],
        ["Host, North", "needs_research", 'Line one\nLine "two"']]);
  });

  it("makes stable 25-row packets and rejects an invalid status before preview", () => {
    const rows = [["id", "name", "status"], ...Array.from({length: 26}, (_, index) =>
      [`host-${index + 1}`, `Host ${index + 1}`, "needs_research"])];
    const mapping = {organizerId: 0, name: 1, researchStatus: 2, summary: -1};
    const first = salesImportPacket(rows, mapping, "reviewed-file", "a".repeat(64), 0);
    const second = salesImportPacket(rows, mapping, "reviewed-file", "a".repeat(64), 1);
    expect(first.rows).toHaveLength(25);
    expect(second.rows).toEqual([{sourceRowId: "row-27", organizerId: "host-26",
      name: "Host 26", researchStatus: "needs_research"}]);
    rows[26][2] = "ready_to_send";
    expect(() => salesImportPacket(rows, mapping, "reviewed-file", "a".repeat(64), 1))
      .toThrow("Row 27: research status is not recognized.");
  });

  it("keeps missing canonical identities unresolved for server review", () => {
    const packet = salesImportPacket([["name", "status"],
      ["North Club", "needs_research"]],
    {organizerId: -1, name: 0, researchStatus: 1, summary: -1},
    "reviewed-file", "a".repeat(64), 0);
    expect(packet.rows[0].organizerId).toBeNull();
  });
});
