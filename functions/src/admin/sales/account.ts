import type {SalesAccount} from "./types";

function text(value: unknown, maximum: number): string | null {
  return typeof value === "string" &&
    value.length > 0 &&
    value.length <= maximum ?
    value :
    null;
}

/** Creates a private companion for a verified canonical organizer. */
export function newSalesAccount(
  organizerId: string,
  organizer: Record<string, unknown>,
  actorUid: string,
  now: string,
  researchStatus: SalesAccount["researchStatus"] = "new",
): SalesAccount {
  const name = text(organizer.name, 160) ?? organizerId;
  const city = text(organizer.cityName, 160);
  const market = text(organizer.locationMarketId, 96);
  const eventTypes: string[] = [];
  const searchTokens = [
    ...new Set(
      [name, city, market, organizerId]
        .filter((value): value is string => !!value)
        .flatMap((value) =>
          value
            .normalize("NFKD")
            .toLowerCase()
            .split(/[^a-z0-9]+/)
            .filter((word) => word.length >= 2),
        ),
    ),
  ].slice(0, 40);
  return {
    schemaVersion: 1,
    classification: "sales_private",
    organizerId,
    revision: 1,
    researchStatus,
    assignedOwnerUid: actorUid,
    summary: null,
    nextAction: null,
    suppressionStatus: "clear",
    suppressionReason: null,
    suppressionAt: null,
    suppressionBy: null,
    duplicateReviewRequired: false,
    qualificationPolicy: null,
    name,
    city,
    market,
    marketLabel: null,
    eventTypes,
    cohortIds: [],
    cohortMutationId: "initial",
    searchTokens,
    createdAt: now,
    updatedAt: now,
    updatedBy: actorUid,
  };
}
