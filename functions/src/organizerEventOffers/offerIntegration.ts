/** Source release boundary shared by Host issuance and recipient checkout.
 * No caller or environment flag may bypass the remaining rollout checks.
 */
export function eventOfferIntegrationReady(): boolean {
  return false;
}
