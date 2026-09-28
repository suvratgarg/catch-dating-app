import {describe, expect, it} from "vitest";
import {parseSalesCsv, salesImportPacket} from "./salesCsv";

describe("Sales CSV import mapping", () => {
  it("parses quoted commas, newlines, escaped quotes, and a BOM", () => {
    expect(parseSalesCsv("\uFEFFname,status,summary\r\n" +
      '"Host, North",needs_research,"Line one\nLine ""two"""\r\n'))
      .toEqual([["name", "status", "summary"],
        ["Host, North", "needs_research", 'Line one\nLine "two"']]);
  });

  it("makes stable batches and preserves original cells without trusting statuses", () => {
    const rows = [["id", "name", "status"], ...Array.from({length: 26}, (_, index) =>
      [`host-${index + 1}`, `Host ${index + 1}`, "needs_research"])];
    const mapping = {organizerId: 0, name: 1, researchStatus: 2, summary: -1};
    const first = salesImportPacket(rows, mapping, "reviewed-file", "a".repeat(64), 0);
    const second = salesImportPacket(rows, mapping, "reviewed-file", "a".repeat(64), 1);
    expect(first.rows).toHaveLength(25);
    expect(second.rows[0]).toMatchObject({sourceRowId: "row-27", organizerId: "host-26",
      name: "Host 26", researchStatus: "needs_research"});
    expect(second.rows[0].originalCells).toEqual([
      {column: "id", value: "host-26"}, {column: "name", value: "Host 26"},
      {column: "status", value: "needs_research"},
    ]);
    rows[26][2] = "ready_to_send";
    const unknown = salesImportPacket(rows, mapping, "reviewed-file", "a".repeat(64), 1);
    expect(unknown.rows[0].researchStatus).toBe("needs_research");
    expect(unknown.rows[0].originalCells?.[2].value).toBe("ready_to_send");
  });

  it("keeps missing canonical identities unresolved for server review", () => {
    const packet = salesImportPacket([["name", "status"],
      ["North Club", "needs_research"]],
    {organizerId: -1, name: 0, researchStatus: 1, summary: -1},
    "reviewed-file", "a".repeat(64), 0);
    expect(packet.rows[0].organizerId).toBeNull();
  });

  it("needs only a name column and normalizes familiar status labels", () => {
    const rows = [["Host", "Old status", "Old score"], ["North Club", "Ready for review", "85"]];
    const unmapped = salesImportPacket(rows,
      {organizerId: -1, name: 0, researchStatus: -1, summary: -1}, "file", "a".repeat(64), 0);
    expect(unmapped.rows[0].researchStatus).toBe("needs_research");
    expect(unmapped.rows[0].originalCells?.[2]).toEqual({column: "Old score", value: "85"});
    const mapped = salesImportPacket(rows,
      {organizerId: -1, name: 0, researchStatus: 1, summary: -1}, "file", "a".repeat(64), 0);
    expect(mapped.rows[0].researchStatus).toBe("ready_for_review");
  });
});
