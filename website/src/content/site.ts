import type {StoreCtaCopy} from "./types";

export const ownerGatedSiteDestinations = {
  contactHref: "",
} as const;

export const storeCtaCopy = [
  {
    platform: "ios",
    kicker: "Download on the",
    label: "App Store",
    shortLabel: "iOS",
  },
  {
    platform: "android",
    kicker: "Get it on",
    label: "Google Play",
    shortLabel: "Play",
  },
] as const satisfies readonly StoreCtaCopy[];
