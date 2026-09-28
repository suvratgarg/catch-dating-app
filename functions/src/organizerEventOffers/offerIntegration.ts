import {readPrivateEventReleaseReadiness} from
  "../shared/privateEventReleaseConfig";

/** Server-read boundary shared by Host issuance and recipient checkout. */
export async function eventOfferIntegrationReady(): Promise<boolean> {
  return (await readPrivateEventReleaseReadiness()).offers;
}
