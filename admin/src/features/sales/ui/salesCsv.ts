import type {SalesImportPacket, SalesResearchStatus} from "../api/salesTypes";

const statuses = new Set<SalesResearchStatus>([
  "new", "needs_research", "ready_for_review", "qualified", "benchmark_only",
  "no_fit", "archived",
]);

export function parseSalesCsv(source: string): string[][] {
  const rows: string[][] = [];
  let row: string[] = [];
  let field = "";
  let quoted = false;
  for (let index = 0; index < source.length; index += 1) {
    const char = source[index];
    if (char === '"') {
      if (quoted && source[index + 1] === '"') {field += '"'; index += 1;}
      else if (quoted) quoted = false;
      else if (!field) quoted = true;
      else throw new Error("CSV has an unexpected quote. Check the file format.");
    } else if (quoted) field += char;
    else if (char === ",") {row.push(field); field = "";}
    else if (char === "\n" || char === "\r") {
      if (char === "\r" && source[index + 1] === "\n") index += 1;
      row.push(field); field = "";
      if (row.some((cell) => cell.trim())) rows.push(row);
      row = [];
    } else field += char;
  }
  if (quoted) throw new Error("CSV has an unclosed quoted value.");
  if (field || row.length) {
    row.push(field);
    if (row.some((cell) => cell.trim())) rows.push(row);
  }
  if (rows.length < 2) throw new Error("CSV needs a header and at least one data row.");
  if (rows.length > 501) throw new Error("Limit this upload to 500 rows; split larger files.");
  const width = rows[0].length;
  if (rows.some((cells) => cells.length !== width)) {
    throw new Error("CSV rows have different column counts. Check quoting and separators.");
  }
  rows[0][0] = rows[0][0].replace(/^\uFEFF/u, "");
  return rows;
}

export interface SalesCsvMapping {
  organizerId: number;
  name: number;
  researchStatus: number;
  summary: number;
}

export function salesImportPacket(rows: string[][], mapping: SalesCsvMapping,
  sourceId: string, contentHash: string, batch: number): SalesImportPacket {
  if (!/^[A-Za-z0-9][A-Za-z0-9._:-]{0,95}$/u.test(sourceId.trim())) {
    throw new Error("Source ID must start with a letter or digit and use at most 96 letters, digits, dots, underscores, colons, or hyphens.");
  }
  if (mapping.name < 0 || mapping.researchStatus < 0) {
    throw new Error("Map both host name and research status before previewing.");
  }
  const batchRows = rows.slice(1 + batch * 25, 1 + (batch + 1) * 25);
  if (!batchRows.length) throw new Error("This batch has no rows.");
  const mapped = batchRows.map((cells, index) => {
    const line = batch * 25 + index + 2;
    const name = cells[mapping.name]?.trim() ?? "";
    const status = cells[mapping.researchStatus]?.trim() as SalesResearchStatus;
    if (!name) throw new Error(`Row ${line}: host name is blank.`);
    if (!statuses.has(status)) throw new Error(`Row ${line}: research status is not recognized.`);
    const organizerId = mapping.organizerId < 0 ? null :
      (cells[mapping.organizerId]?.trim() || null);
    const summary = mapping.summary < 0 ? undefined :
      (cells[mapping.summary]?.trim() || null);
    return {sourceRowId: `row-${line}`, organizerId, name,
      researchStatus: status, ...(summary === undefined ? {} : {summary})};
  });
  return {sourceId: sourceId.trim(), contentHash, mappingVersion: "csv-v1",
    rows: mapped};
}
