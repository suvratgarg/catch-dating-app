export type ExternalRosterProvider =
  "generic" | "luma" | "eventbrite" | "partiful" | "posh" |
  "bookmyshow" | "district" | "sortmyscene" | "airbnb";

export type RosterAdapterId =
  "generic-v1" | "luma-v1" | "eventbrite-v1" | "partiful-v1" |
  "posh-v1" | "sample-required";

export type RosterAdapterSupport = "verified" | "generic" | "sampleRequired";

export interface RosterAdapterDetection {
  adapterId: RosterAdapterId;
  support: RosterAdapterSupport;
  confidence: number;
}

export interface RosterMatrix {
  headers: string[];
  rows: string[][];
}

export interface NormalizedRosterImportRow {
  rowId: string;
  displayName: string;
  phone: string | null;
  email: string | null;
  externalReference: string | null;
  arrivalGroup: string | null;
  ticketType: string | null;
  status: "invited" | "registered" | "waitlisted";
}

export interface PreparedRosterImport {
  adapter: RosterAdapterDetection;
  rows: NormalizedRosterImportRow[];
}

const verifiedProviderAdapters: Partial<
  Record<ExternalRosterProvider, RosterAdapterId>
> = {
  luma: "luma-v1",
  eventbrite: "eventbrite-v1",
  partiful: "partiful-v1",
  posh: "posh-v1",
};

const sampleRequiredProviders = new Set<ExternalRosterProvider>([
  "bookmyshow",
  "district",
  "sortmyscene",
  "airbnb",
]);

const signatures: Record<Exclude<RosterAdapterId,
  "generic-v1" | "sample-required">, string[]> = {
    "luma-v1": [
      "name",
      "approvalstatus",
      "registrationdate",
      "tickettype",
      "guestkey",
    ],
    "eventbrite-v1": [
      "firstname",
      "lastname",
      "orderid",
      "tickettype",
      "attendeestatus",
    ],
    "partiful-v1": ["name", "rsvpstatus", "phonenumber", "email"],
    "posh-v1": ["name", "orderid", "tickettype", "phonenumber"],
  };

export function detectRosterAdapter(
  headers: string[],
  providerHint?: ExternalRosterProvider
): RosterAdapterDetection {
  if (providerHint === "generic") {
    return {adapterId: "generic-v1", support: "generic", confidence: 1};
  }
  if (providerHint && sampleRequiredProviders.has(providerHint)) {
    return {
      adapterId: "sample-required",
      support: "sampleRequired",
      confidence: 1,
    };
  }
  const hintedAdapter = providerHint ? verifiedProviderAdapters[providerHint] :
    undefined;
  if (hintedAdapter) {
    return {adapterId: hintedAdapter, support: "verified", confidence: 1};
  }

  const normalizedHeaders = new Set(headers.map(normalizeHeader));
  const candidates = Object.entries(signatures).map(([adapterId, values]) => ({
    adapterId: adapterId as RosterAdapterId,
    confidence: values.filter((value) => normalizedHeaders.has(value)).length /
      values.length,
  })).sort((left, right) => right.confidence - left.confidence);
  const best = candidates[0];
  if (best && best.confidence >= 0.6) {
    return {
      adapterId: best.adapterId,
      support: "verified",
      confidence: best.confidence,
    };
  }
  return {adapterId: "generic-v1", support: "generic", confidence: 0};
}

export function normalizeRosterMatrix(
  matrix: RosterMatrix,
  adapter: RosterAdapterDetection
): RosterMatrix {
  if (adapter.adapterId !== "eventbrite-v1" ||
      findHeader(matrix.headers, fullNameAliases) !== null) {
    return matrix;
  }
  const firstName = findHeader(matrix.headers, new Set(["firstname"]));
  const lastName = findHeader(matrix.headers, new Set(["lastname"]));
  if (firstName === null && lastName === null) return matrix;
  return {
    headers: [...matrix.headers, "Guest name"],
    rows: matrix.rows.map((row) => [
      ...row,
      [valueAt(row, firstName), valueAt(row, lastName)]
        .filter((value) => value.length > 0)
        .join(" "),
    ]),
  };
}

export function prepareCsvRosterImport(
  source: string,
  providerHint?: ExternalRosterProvider
): PreparedRosterImport {
  const matrix = parseCsvMatrix(source);
  if (matrix.length < 2) throw new Error("roster_missing_rows");
  if (matrix[0].length > 40) throw new Error("roster_too_many_columns");
  const headers = uniqueHeaders(matrix[0]);
  const adapter = detectRosterAdapter(headers, providerHint);
  const normalized = normalizeRosterMatrix({
    headers,
    rows: matrix.slice(1).filter((row) => row.some((value) => value.trim())),
  }, adapter);
  const mapping = suggestRosterMapping(normalized.headers, adapter.adapterId);
  const nameIndex = mapping.displayName;
  if (nameIndex === null) throw new Error("roster_missing_name_column");
  const rows: NormalizedRosterImportRow[] = [];
  for (let index = 0; index < normalized.rows.length && rows.length < 250;
    index += 1) {
    const row = normalized.rows[index];
    const displayName = valueAt(row, nameIndex);
    if (!displayName) continue;
    rows.push({
      rowId: String(index + 2),
      displayName,
      phone: nullableValueAt(row, mapping.phone),
      email: nullableValueAt(row, mapping.email),
      externalReference: nullableValueAt(row, mapping.externalReference),
      arrivalGroup: nullableValueAt(row, mapping.arrivalGroup),
      ticketType: nullableValueAt(row, mapping.ticketType),
      status: rosterStatus(nullableValueAt(row, mapping.status)),
    });
  }
  if (rows.length === 0) throw new Error("roster_missing_guest_names");
  return {adapter, rows};
}

export function parseCsvMatrix(source: string): string[][] {
  const text = source.startsWith("\uFEFF") ? source.slice(1) : source;
  const rows: string[][] = [];
  let row: string[] = [];
  let field = "";
  let quoted = false;
  for (let index = 0; index < text.length; index += 1) {
    const character = text[index];
    if (quoted) {
      if (character === "\"") {
        if (text[index + 1] === "\"") {
          field += "\"";
          index += 1;
        } else {
          quoted = false;
        }
      } else {
        field += character;
      }
      continue;
    }
    if (character === "\"") {
      quoted = true;
    } else if (character === ",") {
      row.push(field.trim());
      field = "";
    } else if (character === "\n" || character === "\r") {
      if (character === "\r" && text[index + 1] === "\n") index += 1;
      row.push(field.trim());
      if (row.some((value) => value.length > 0)) rows.push(row);
      row = [];
      field = "";
    } else {
      field += character;
    }
  }
  if (quoted) throw new Error("roster_malformed_csv");
  if (field.length > 0 || row.length > 0) {
    row.push(field.trim());
    if (row.some((value) => value.length > 0)) rows.push(row);
  }
  return rows;
}

function suggestRosterMapping(
  headers: string[],
  adapterId: RosterAdapterId
): {
  displayName: number | null;
  phone: number | null;
  email: number | null;
  externalReference: number | null;
  arrivalGroup: number | null;
  ticketType: number | null;
  status: number | null;
} {
  return {
    displayName: findHeader(headers, fullNameAliases),
    phone: findHeader(headers, new Set([
      "phone", "phonenumber", "mobile", "mobilenumber", "contactnumber",
      "whatsapp", "phonee164", "guestphone",
    ])),
    email: findHeader(headers, new Set([
      "email", "emailaddress", "guestemail", "attendeeemail",
    ])),
    externalReference: findHeader(
      headers,
      externalReferenceAliases(adapterId)
    ),
    arrivalGroup: findHeader(headers, arrivalGroupAliases(adapterId)),
    ticketType: findHeader(headers, new Set([
      "ticket", "tickettype", "category", "pass", "ticketname",
    ])),
    status: findHeader(headers, new Set([
      "status", "registrationstatus", "bookingstatus", "rsvpstatus",
      "approvalstatus", "attendeestatus", "checkinstatus",
    ])),
  };
}

/**
 * Returns attendee-level provider identifiers. Group/order identifiers are
 * deliberately excluded for adapters where one booking can contain multiple
 * guests; those values belong in arrivalGroup instead.
 */
function externalReferenceAliases(adapterId: RosterAdapterId): Set<string> {
  if (adapterId === "eventbrite-v1") {
    return new Set(["attendeeid", "ticketid", "ticketkey", "id"]);
  }
  if (adapterId === "posh-v1") {
    return new Set(["attendeeid", "ticketid", "ticketkey", "id"]);
  }
  if (adapterId === "luma-v1") {
    return new Set(["guestkey", "guestid", "attendeeid", "id"]);
  }
  return new Set([
    "id", "reference", "bookingid", "orderid", "ticketid", "guestkey",
    "ticketkey", "attendeeid", "order", "ordernumber",
  ]);
}

/** Returns provider booking/group fields used to associate arriving guests. */
function arrivalGroupAliases(adapterId: RosterAdapterId): Set<string> {
  const common = [
    "arrivalgroup", "groupid", "partyid", "bookinggroup", "buyeremail",
    "ticketbuyeremail",
  ];
  if (adapterId === "eventbrite-v1" || adapterId === "posh-v1") {
    return new Set([
      "orderid", "ordernumber", "order", "bookingid", ...common,
    ]);
  }
  return new Set(common);
}

function uniqueHeaders(headers: string[]): string[] {
  const counts = new Map<string, number>();
  return headers.map((raw, index) => {
    const base = raw.trim() || `Column ${index + 1}`;
    const count = (counts.get(base) ?? 0) + 1;
    counts.set(base, count);
    return count === 1 ? base : `${base} (${count})`;
  });
}

function nullableValueAt(row: string[], index: number | null): string | null {
  const value = valueAt(row, index);
  return value.length > 0 ? value : null;
}

function rosterStatus(value: string | null):
  "invited" | "registered" | "waitlisted" {
  const normalized = normalizeHeader(value ?? "");
  if (["waitlist", "waitlisted", "waiting"].includes(normalized)) {
    return "waitlisted";
  }
  if (["invited", "invite", "pending"].includes(normalized)) {
    return "invited";
  }
  return "registered";
}

const fullNameAliases = new Set([
  "name",
  "fullname",
  "guestname",
  "attendeename",
  "participantname",
  "ticketbuyer",
  "ticketbuyername",
  "buyername",
  "customername",
]);

function findHeader(headers: string[], aliases: Set<string>): number | null {
  const index = headers.findIndex(
    (header) => aliases.has(normalizeHeader(header))
  );
  return index < 0 ? null : index;
}

function valueAt(row: string[], index: number | null): string {
  return index === null ? "" : (row[index] ?? "").trim();
}

export function normalizeHeader(value: string): string {
  return value.toLowerCase().replace(/[^a-z0-9]/g, "");
}
