import type {
  OrganizerContactDocument,
  OrganizerContactEventEdgeDocument,
} from "../shared/generated/firestoreAdminTypes";

type ContactFields = Pick<OrganizerContactDocument,
  "organizerId" | "displayName" | "displayNameOverride" |
  "phoneE164" | "email">;

type EventEdgeFields = Pick<OrganizerContactEventEdgeDocument,
  "organizerId" | "attendeeId" | "sourceUpdatedAt" | "displayName" |
  "phoneE164" | "email">;

/** Reads only the operational fields already stored on this CRM contact. */
export function organizerContactVisibleFields(contact: ContactFields): {
  displayName: string;
  sourceDisplayName: string;
  displayNameOverride: string | null;
  phoneE164: string | null;
  email: string | null;
} {
  return {
    displayName: contact.displayNameOverride ?? contact.displayName,
    sourceDisplayName: contact.displayName,
    displayNameOverride: contact.displayNameOverride ?? null,
    phoneE164: contact.phoneE164,
    email: contact.email,
  };
}

/**
 * Selects fields from organizer-scoped operational facts. Legacy contact fields
 * are flattened and carry no endpoint provenance: retaining them does not
 * establish ownership or permission, and lost historical values cannot be
 * reconstructed here.
 */
export function organizerContactProjectedFields(params: {
  contact: ContactFields;
  edges: ReadonlyArray<EventEdgeFields>;
  hasStandaloneOrigin: boolean;
}): {displayName: string; phoneE164: string | null; email: string | null} {
  const {contact, hasStandaloneOrigin} = params;
  const edges = params.edges
    .filter((edge) => edge.organizerId === contact.organizerId)
    .sort((left, right) =>
      right.sourceUpdatedAt.toMillis() - left.sourceUpdatedAt.toMillis() ||
      left.attendeeId.localeCompare(right.attendeeId)
    );
  const edgePhone = edges.find((edge) => edge.phoneE164 !== null)
    ?.phoneE164 ?? null;
  const edgeEmail = edges.find((edge) => edge.email !== null)?.email ?? null;
  return {
    displayName: hasStandaloneOrigin ? contact.displayName :
      edges[0]?.displayName ?? contact.displayName,
    phoneE164: hasStandaloneOrigin ? contact.phoneE164 ?? edgePhone :
      edgePhone ?? contact.phoneE164,
    email: hasStandaloneOrigin ? contact.email ?? edgeEmail :
      edgeEmail ?? contact.email,
  };
}
