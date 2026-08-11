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
  const index = headers.findIndex((header) => aliases.has(normalizeHeader(header)));
  return index < 0 ? null : index;
}

function valueAt(row: string[], index: number | null): string {
  return index === null ? "" : (row[index] ?? "").trim();
}

export function normalizeHeader(value: string): string {
  return value.toLowerCase().replace(/[^a-z0-9]/g, "");
}
