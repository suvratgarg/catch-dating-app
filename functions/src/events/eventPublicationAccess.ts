/**
 * Publication is independent of operational lifecycle and booking provenance.
 * Legacy events predate setup state; malformed new records fail closed.
 * This predicate grants no organizer, booking, payment or attendee authority.
 */
export function isEventPubliclyAccessible(event: object): boolean {
  if (Object.prototype.hasOwnProperty.call(event, "publicationState")) {
    return (event as {publicationState?: unknown}).publicationState ===
      "published";
  }
  return !Object.prototype.hasOwnProperty.call(event, "setupRevision");
}
