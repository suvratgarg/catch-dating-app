export type LaunchMarketStatus = "launched" | "planned" | "paused" |
  "retired";

export interface CanonicalMarket {
  marketId: string;
  cityId: string;
  slug: string;
  label: string;
  cityLabel: string;
  regionCode: string;
  regionName: string;
  countryIsoCode: string;
  countryName: string;
  currencyCode: string;
  dialCode: string;
  timeZone: string;
  latitude: number;
  longitude: number;
  aliases: string[];
  launchStatus: LaunchMarketStatus;
  profileSelectable: boolean;
  hostCreatable: boolean;
  eventCreatable: boolean;
  exploreVisible: boolean;
}

const marketEntries: CanonicalMarket[] = [
  market({
    marketId: "in-mh-mumbai",
    cityId: "in-mh-mumbai",
    slug: "mumbai",
    label: "Mumbai",
    cityLabel: "Mumbai",
    regionCode: "MH",
    regionName: "Maharashtra",
    countryIsoCode: "IN",
    countryName: "India",
    currencyCode: "INR",
    dialCode: "+91",
    timeZone: "Asia/Kolkata",
    latitude: 19.076,
    longitude: 72.8777,
    aliases: ["mumbai", "bombay"],
    launchStatus: "launched",
  }),
  market({
    marketId: "in-mp-indore",
    cityId: "in-mp-indore",
    slug: "indore",
    label: "Indore",
    cityLabel: "Indore",
    regionCode: "MP",
    regionName: "Madhya Pradesh",
    countryIsoCode: "IN",
    countryName: "India",
    currencyCode: "INR",
    dialCode: "+91",
    timeZone: "Asia/Kolkata",
    latitude: 22.7196,
    longitude: 75.8577,
    aliases: ["indore"],
    launchStatus: "launched",
  }),
  market({
    marketId: "in-dl-delhi-ncr",
    cityId: "in-dl-new-delhi",
    slug: "delhi-ncr",
    label: "Delhi NCR",
    cityLabel: "New Delhi",
    regionCode: "DL",
    regionName: "Delhi",
    countryIsoCode: "IN",
    countryName: "India",
    currencyCode: "INR",
    dialCode: "+91",
    timeZone: "Asia/Kolkata",
    latitude: 28.7041,
    longitude: 77.1025,
    aliases: ["delhi", "new-delhi", "delhi-ncr", "ncr"],
  }),
  market({
    marketId: "in-ka-bengaluru",
    cityId: "in-ka-bengaluru",
    slug: "bengaluru",
    label: "Bengaluru",
    cityLabel: "Bengaluru",
    regionCode: "KA",
    regionName: "Karnataka",
    countryIsoCode: "IN",
    countryName: "India",
    currencyCode: "INR",
    dialCode: "+91",
    timeZone: "Asia/Kolkata",
    latitude: 12.9716,
    longitude: 77.5946,
    aliases: ["bengaluru", "bangalore"],
  }),
  market({
    marketId: "in-tg-hyderabad",
    cityId: "in-tg-hyderabad",
    slug: "hyderabad",
    label: "Hyderabad",
    cityLabel: "Hyderabad",
    regionCode: "TG",
    regionName: "Telangana",
    countryIsoCode: "IN",
    countryName: "India",
    currencyCode: "INR",
    dialCode: "+91",
    timeZone: "Asia/Kolkata",
    latitude: 17.385,
    longitude: 78.4867,
    aliases: ["hyderabad"],
  }),
  market({
    marketId: "in-tn-chennai",
    cityId: "in-tn-chennai",
    slug: "chennai",
    label: "Chennai",
    cityLabel: "Chennai",
    regionCode: "TN",
    regionName: "Tamil Nadu",
    countryIsoCode: "IN",
    countryName: "India",
    currencyCode: "INR",
    dialCode: "+91",
    timeZone: "Asia/Kolkata",
    latitude: 13.0827,
    longitude: 80.2707,
    aliases: ["chennai", "madras"],
  }),
  market({
    marketId: "in-wb-kolkata",
    cityId: "in-wb-kolkata",
    slug: "kolkata",
    label: "Kolkata",
    cityLabel: "Kolkata",
    regionCode: "WB",
    regionName: "West Bengal",
    countryIsoCode: "IN",
    countryName: "India",
    currencyCode: "INR",
    dialCode: "+91",
    timeZone: "Asia/Kolkata",
    latitude: 22.5726,
    longitude: 88.3639,
    aliases: ["kolkata", "calcutta"],
  }),
  market({
    marketId: "in-mh-pune",
    cityId: "in-mh-pune",
    slug: "pune",
    label: "Pune",
    cityLabel: "Pune",
    regionCode: "MH",
    regionName: "Maharashtra",
    countryIsoCode: "IN",
    countryName: "India",
    currencyCode: "INR",
    dialCode: "+91",
    timeZone: "Asia/Kolkata",
    latitude: 18.5204,
    longitude: 73.8567,
    aliases: ["pune"],
  }),
  market({
    marketId: "in-gj-ahmedabad",
    cityId: "in-gj-ahmedabad",
    slug: "ahmedabad",
    label: "Ahmedabad",
    cityLabel: "Ahmedabad",
    regionCode: "GJ",
    regionName: "Gujarat",
    countryIsoCode: "IN",
    countryName: "India",
    currencyCode: "INR",
    dialCode: "+91",
    timeZone: "Asia/Kolkata",
    latitude: 23.0225,
    longitude: 72.5714,
    aliases: ["ahmedabad"],
  }),
  market({
    marketId: "in-ga-goa",
    cityId: "in-ga-panaji",
    slug: "goa",
    label: "Goa",
    cityLabel: "Panaji",
    regionCode: "GA",
    regionName: "Goa",
    countryIsoCode: "IN",
    countryName: "India",
    currencyCode: "INR",
    dialCode: "+91",
    timeZone: "Asia/Kolkata",
    latitude: 15.4909,
    longitude: 73.8278,
    aliases: ["goa", "panaji", "panjim"],
  }),
  market({
    marketId: "np-p3-kathmandu",
    cityId: "np-p3-kathmandu",
    slug: "kathmandu",
    label: "Kathmandu",
    cityLabel: "Kathmandu",
    regionCode: "P3",
    regionName: "Bagmati Province",
    countryIsoCode: "NP",
    countryName: "Nepal",
    currencyCode: "NPR",
    dialCode: "+977",
    timeZone: "Asia/Kathmandu",
    latitude: 27.7172,
    longitude: 85.324,
    aliases: ["kathmandu"],
  }),
  market({
    marketId: "np-p4-pokhara",
    cityId: "np-p4-pokhara",
    slug: "pokhara",
    label: "Pokhara",
    cityLabel: "Pokhara",
    regionCode: "P4",
    regionName: "Gandaki Province",
    countryIsoCode: "NP",
    countryName: "Nepal",
    currencyCode: "NPR",
    dialCode: "+977",
    timeZone: "Asia/Kathmandu",
    latitude: 28.2096,
    longitude: 83.9856,
    aliases: ["pokhara"],
  }),
  market({
    marketId: "au-nsw-sydney",
    cityId: "au-nsw-sydney",
    slug: "sydney",
    label: "Sydney",
    cityLabel: "Sydney",
    regionCode: "NSW",
    regionName: "New South Wales",
    countryIsoCode: "AU",
    countryName: "Australia",
    currencyCode: "AUD",
    dialCode: "+61",
    timeZone: "Australia/Sydney",
    latitude: -33.8688,
    longitude: 151.2093,
    aliases: ["sydney"],
  }),
  market({
    marketId: "au-vic-melbourne",
    cityId: "au-vic-melbourne",
    slug: "melbourne",
    label: "Melbourne",
    cityLabel: "Melbourne",
    regionCode: "VIC",
    regionName: "Victoria",
    countryIsoCode: "AU",
    countryName: "Australia",
    currencyCode: "AUD",
    dialCode: "+61",
    timeZone: "Australia/Melbourne",
    latitude: -37.8136,
    longitude: 144.9631,
    aliases: ["melbourne"],
  }),
  market({
    marketId: "au-qld-brisbane",
    cityId: "au-qld-brisbane",
    slug: "brisbane",
    label: "Brisbane",
    cityLabel: "Brisbane",
    regionCode: "QLD",
    regionName: "Queensland",
    countryIsoCode: "AU",
    countryName: "Australia",
    currencyCode: "AUD",
    dialCode: "+61",
    timeZone: "Australia/Brisbane",
    latitude: -27.4698,
    longitude: 153.0251,
    aliases: ["brisbane"],
  }),
  market({
    marketId: "us-ny-new-york",
    cityId: "us-ny-new-york",
    slug: "new-york",
    label: "New York",
    cityLabel: "New York",
    regionCode: "NY",
    regionName: "New York",
    countryIsoCode: "US",
    countryName: "United States",
    currencyCode: "USD",
    dialCode: "+1",
    timeZone: "America/New_York",
    latitude: 40.7128,
    longitude: -74.006,
    aliases: ["new-york", "nyc", "new-york-city"],
  }),
  market({
    marketId: "us-ca-san-francisco",
    cityId: "us-ca-san-francisco",
    slug: "san-francisco",
    label: "San Francisco",
    cityLabel: "San Francisco",
    regionCode: "CA",
    regionName: "California",
    countryIsoCode: "US",
    countryName: "United States",
    currencyCode: "USD",
    dialCode: "+1",
    timeZone: "America/Los_Angeles",
    latitude: 37.7749,
    longitude: -122.4194,
    aliases: ["san-francisco", "sf"],
  }),
  market({
    marketId: "us-ca-los-angeles",
    cityId: "us-ca-los-angeles",
    slug: "los-angeles",
    label: "Los Angeles",
    cityLabel: "Los Angeles",
    regionCode: "CA",
    regionName: "California",
    countryIsoCode: "US",
    countryName: "United States",
    currencyCode: "USD",
    dialCode: "+1",
    timeZone: "America/Los_Angeles",
    latitude: 34.0522,
    longitude: -118.2437,
    aliases: ["los-angeles", "la"],
  }),
];

export const canonicalMarkets = Object.freeze(marketEntries);
export const launchedMarketIds = Object.freeze(
  marketEntries
    .filter((entry) => entry.launchStatus === "launched")
    .map((entry) => entry.marketId)
);

const marketById = new Map(
  marketEntries.map((entry) => [entry.marketId, entry])
);
const marketIdByAlias = new Map<string, string>();
for (const entry of marketEntries) {
  for (const alias of [
    entry.marketId,
    entry.cityId,
    entry.slug,
    ...entry.aliases,
  ]) {
    marketIdByAlias.set(slugifyLocationKey(alias), entry.marketId);
  }
}

export function normalizeMarketId(value: string | null | undefined):
  string | null {
  const normalized = slugifyLocationKey(value ?? "");
  if (normalized.length === 0) return null;
  return marketIdByAlias.get(normalized) ?? normalized;
}

export function marketForIdOrAlias(value: string | null | undefined):
  CanonicalMarket | null {
  const marketId = normalizeMarketId(value);
  return marketId == null ? null : marketById.get(marketId) ?? null;
}

export function requireKnownMarket(value: string | null | undefined):
  CanonicalMarket | null {
  const market = marketForIdOrAlias(value);
  return market ?? null;
}

function market(
  entry: Omit<CanonicalMarket,
    "launchStatus" | "profileSelectable" | "hostCreatable" |
    "eventCreatable" | "exploreVisible"> &
    Partial<Pick<CanonicalMarket,
      "launchStatus" | "profileSelectable" | "hostCreatable" |
      "eventCreatable" | "exploreVisible">>
): CanonicalMarket {
  const launched = entry.launchStatus === "launched";
  return {
    ...entry,
    launchStatus: entry.launchStatus ?? "planned",
    aliases: Array.from(new Set(entry.aliases.map(slugifyLocationKey))),
    profileSelectable: entry.profileSelectable ?? launched,
    hostCreatable: entry.hostCreatable ?? launched,
    eventCreatable: entry.eventCreatable ?? launched,
    exploreVisible: entry.exploreVisible ?? launched,
  };
}

function slugifyLocationKey(value: string): string {
  return value
    .trim()
    .toLowerCase()
    .replace(/&/g, " and ")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}
