/** Static listings are display snapshots; checkout always verifies live terms. */
export function publicEventRegistrationProjection(event) {
  if (!event || event.status !== "active" || (event.currency ?? "INR") !== "INR") return null;
  const own = (key) => Object.prototype.hasOwnProperty.call(event, key);
  if (own("publicationState") ? event.publicationState !== "published" : own("setupRevision")) return null;
  const mode = event.publicRegistrationEnabled === true ? event.publicRegistrationMode ?? "free" : "closed";
  if (!["free", "paid", "closed"].includes(mode) || mode === "closed" && event.publicRegistrationMode !== "closed") return null;
  const amountPaise = event.priceInPaise;
  if (!Number.isSafeInteger(amountPaise) || amountPaise < 0 || amountPaise > 100_000_000 ||
    mode === "free" && amountPaise !== 0 || mode === "paid" && amountPaise < 100) return null;
  const admission = event.eventPolicy?.admission;
  const pricing = event.eventPolicy?.pricing;
  if (event.constraints?.maxMen != null || event.constraints?.maxWomen != null ||
    (event.crossPathsPairHeldCount ?? 0) !== 0 || (event.crossPathsPairConfirmedCount ?? 0) !== 0 ||
    Object.values(event.crossPathsPairHeldCohortCounts ?? {}).some((count) => count !== 0)) return null;
  if (event.eventPolicy && (!admission || !pricing || pricing.basePriceInPaise !== amountPaise ||
    admission.format !== "open" || admission.inviteRequired || admission.membershipRequired || admission.manualApprovalRequired ||
    admission.privateAccessPolicy?.mode === "inviteCode" || admission.crossPathsPairInventory?.enabled ||
    admission.balancedRatioPolicy != null || Object.keys(admission.cohortCapacityLimits ?? {}).length > 0 ||
    Object.keys(pricing.cohortAdjustmentsInPaise ?? {}).length > 0 || (pricing.demandPricingRules ?? []).length > 0)) return null;
  return {registrationMode: mode, amountPaise, currency: "INR"};
}
