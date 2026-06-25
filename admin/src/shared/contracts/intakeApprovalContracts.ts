import type {ClubDocument} from "../../../../functions/src/shared/generated/clubDocument";
import type {EventDocument} from "../../../../functions/src/shared/generated/eventDocument";
import type {ExternalEventDocument} from "../../../../functions/src/shared/generated/externalEventDocument";

/**
 * Durable, cross-surface shapes produced after admin intake approval.
 *
 * Admin bridge JSON and screen view models can stay feature-local, but approved
 * organizer listings and events must map back to schema-generated contract
 * documents so the app, website, and backend do not drift.
 */
export type ApprovedOrganizerListingContract = ClubDocument;
export type ApprovedCatchEventContract = EventDocument;
export type ApprovedExternalEventContract = ExternalEventDocument;

export type IntakeApprovalPublicationTarget =
  | "clubs"
  | "events"
  | "externalEvents";

export interface IntakeApprovalContractMap {
  clubs: ApprovedOrganizerListingContract;
  events: ApprovedCatchEventContract;
  externalEvents: ApprovedExternalEventContract;
}
