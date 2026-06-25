import type {ClubClaimRole} from "../../firebase";
import type {HostListing} from "../organizers/types";

export type ClaimFlowStep = "listing" | "role" | "verify" | "submitted";
export type ClaimVerificationMethodId = "publicProof" | "email" | "phone";
export type ClaimRole = ClubClaimRole;

export interface ClaimVerificationMethod {
  id: ClaimVerificationMethodId;
  title: string;
  body: string;
}

export const claimRoleOptions: Array<{value: ClubClaimRole; label: string}> = [
  {value: "owner", label: "Owner"},
  {value: "founder", label: "Founder"},
  {value: "manager", label: "Manager"},
  {value: "marketer", label: "Marketing"},
  {value: "venueManager", label: "Venue manager"},
  {value: "other", label: "Other"},
];

export const claimFlowSteps: Array<{id: ClaimFlowStep; label: string}> = [
  {id: "listing", label: "Find listing"},
  {id: "role", label: "Your role"},
  {id: "verify", label: "Verify"},
  {id: "submitted", label: "Review"},
];

export const claimVerificationMethods: ClaimVerificationMethod[] = [
  {
    id: "publicProof",
    title: "Public proof links",
    body: "Submit official sites, event pages, Instagram bios, Linktree, Luma, or venue pages that connect you to this organizer.",
  },
  {
    id: "email",
    title: "Official email",
    body: "Use a domain or booking address that appears publicly for the organizer or venue.",
  },
  {
    id: "phone",
    title: "Venue or business phone",
    body: "Use the publicly listed business phone so Catch can confirm the claim before owner tools unlock.",
  },
];

export function claimWhileYouWaitItems(listing: HostListing | null) {
  return [
    {
      title: "Keep proof links stable",
      body: "Leave the website, Instagram, event page, or Linktree proof available while Catch reviews ownership.",
    },
    {
      title: "Draft the first Catch event",
      body: listing ?
        `Prepare the next ${listing.category.toLowerCase()} with capacity, price, admission rules, and waitlist plan.` :
        "Prepare the next event with capacity, price, admission rules, and waitlist plan.",
    },
    {
      title: "Watch for follow-up",
      body: "Catch may ask for a public-page edit, email confirmation, or additional owner-safe source before approval.",
    },
    {
      title: "Do not promise automation yet",
      body: "Instagram DM verification still needs backend support, so manual review remains the source of truth.",
    },
  ];
}

export function nullableString(value: FormDataEntryValue | null): string | null {
  if (typeof value !== "string") return null;
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : null;
}

export function parseProofUrls(value: FormDataEntryValue | null): string[] {
  if (typeof value !== "string") return [];
  const urls = value
    .split(/[\n,]+/)
    .map((item) => item.trim())
    .filter(Boolean)
    .map((item) =>
      item.startsWith("http://") || item.startsWith("https://") ?
        item :
        `https://${item}`
    )
    .filter((item) => {
      try {
        const url = new URL(item);
        return url.protocol === "http:" || url.protocol === "https:";
      } catch {
        return false;
      }
    });
  return [...new Set(urls)].slice(0, 8);
}

export function readableError(error: unknown): string {
  return error instanceof Error ?
    error.message :
    "Something went wrong. Please try again.";
}
