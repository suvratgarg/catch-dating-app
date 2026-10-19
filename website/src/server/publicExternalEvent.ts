import {validateExternalEventDocument} from "../../../tool/contracts/generated/schema_contract_validators.mjs";
import {projectExternalEventDocument} from "../../scripts/next/externalEventProjection.mjs";
import {publicDocumentId, publicHttpsUrl, synthetic} from "./publicReadPolicy.ts";
import type {HostListingExternalEvent} from "../features/organizers/types";
export function publicExternalEvent(id: string, data: Record<string, unknown>): {
  organizerId: string; event: HostListingExternalEvent;
} | null {
  if (!publicDocumentId(id) || data.eventId !== id || synthetic(data) ||
      data.status !== "active" || data.publicationStatus !== "public" ||
      !validateExternalEventDocument(data)) return null;
  const booking = data.booking as Record<string, unknown>;
  const discovery = data.discovery as Record<string, unknown>;
  if (discovery.availability !== "read_only_external" || booking.mode !== "external_outbound_only" ||
      ["catchBookingEnabled", "catchPaymentsEnabled", "catchReservationsEnabled", "catchWaitlistEnabled"]
        .some(key => booking[key] !== false)) return null;
  const result = projectExternalEventDocument(data);
  if (!result || !publicDocumentId(result.canonicalHostId) || !publicHttpsUrl(result.projection.sourceHref)) return null;
  return {organizerId: result.canonicalHostId, event: result.projection as HostListingExternalEvent};
}
