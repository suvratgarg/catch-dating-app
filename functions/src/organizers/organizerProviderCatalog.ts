import {OrganizerProviderSetupCallableResponse} from
  "../shared/generated/organizerProviderSetupCallableResponse";

export type ProviderCatalogEntry =
  OrganizerProviderSetupCallableResponse["providers"][number];

const none = {
  eventList: false,
  rosterIdentity: false,
  registrationStatus: false,
  providerCheckIn: false,
  orderAmount: false,
  refundStatus: false,
  referralCode: false,
  webhooks: false,
  writeBookings: false,
};

/** Honest, field-scoped product availability. Never infer sync from a name. */
export const organizerProviderCatalog: ProviderCatalogEntry[] = [
  {
    provider: "generic",
    displayName: "Spreadsheet or another platform",
    adapterClass: "C",
    availability: "manualOnly",
    importSupport: "generic",
    connectionMethod: "none",
    capabilities: {...none, fileImport: true},
    requirement: "Import CSV/XLSX or add guests manually.",
  },
  {
    provider: "luma",
    displayName: "Luma",
    adapterClass: "A",
    availability: "available",
    importSupport: "verified",
    connectionMethod: "apiKey",
    capabilities: {
      ...none,
      fileImport: true,
      eventList: true,
      rosterIdentity: true,
      registrationStatus: true,
      providerCheckIn: true,
    },
    requirement: "A calendar-scoped Luma API key and Luma Plus.",
  },
  {
    provider: "eventbrite",
    displayName: "Eventbrite",
    adapterClass: "A",
    availability: "configurationRequired",
    importSupport: "verified",
    connectionMethod: "oauth",
    capabilities: {...none, fileImport: true},
    requirement: "Catch must complete Eventbrite application and OAuth setup.",
  },
  {
    provider: "partiful",
    displayName: "Partiful",
    adapterClass: "C",
    availability: "exportOnly",
    importSupport: "verified",
    connectionMethod: "none",
    capabilities: {...none, fileImport: true},
    requirement: "Export the guest list from Partiful and import it here.",
  },
  {
    provider: "posh",
    displayName: "POSH",
    adapterClass: "unclassified",
    availability: "exportOnly",
    importSupport: "verified",
    connectionMethod: "none",
    capabilities: {...none, fileImport: true},
    requirement: "Use a current POSH export; direct access is not claimed.",
  },
  {
    provider: "bookmyshow",
    displayName: "BookMyShow",
    adapterClass: "D",
    availability: "sampleRequired",
    importSupport: "sampleRequired",
    connectionMethod: "partner",
    capabilities: {...none, fileImport: true},
    requirement:
      "Provide a current organizer export; direct access needs written " +
      "approval.",
  },
  {
    provider: "district",
    displayName: "District",
    adapterClass: "D",
    availability: "sampleRequired",
    importSupport: "sampleRequired",
    connectionMethod: "partner",
    capabilities: {...none, fileImport: true},
    requirement:
      "Provide a current organizer export; direct access needs written " +
      "approval.",
  },
  {
    provider: "sortmyscene",
    displayName: "SortMyScene",
    adapterClass: "E",
    availability: "sampleRequired",
    importSupport: "sampleRequired",
    connectionMethod: "none",
    capabilities: {...none, fileImport: true},
    requirement:
      "Provide a current organizer export before Catch claims a preset.",
  },
  {
    provider: "airbnb",
    displayName: "Airbnb Experiences",
    adapterClass: "D",
    availability: "partnerAccessRequired",
    importSupport: "sampleRequired",
    connectionMethod: "partner",
    capabilities: {...none, fileImport: true},
    requirement:
      "Direct sync requires Airbnb program approval and permitted scopes.",
  },
];
