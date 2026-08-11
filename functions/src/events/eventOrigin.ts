import {HttpsError} from "firebase-functions/v2/https";
import {EventDocument} from "../shared/generated/firestoreAdminTypes";

/** Prevents Catch booking flows from acting on companion-only events. */
export function requireCatchBookingAuthority(event: EventDocument): void {
  if (event.eventOrigin?.bookingAuthority === "external") {
    throw new HttpsError(
      "failed-precondition",
      "Booking for this event stays with the Host's original platform."
    );
  }
}
