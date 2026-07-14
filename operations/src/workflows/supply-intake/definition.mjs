export const SUPPLY_INTAKE_PRIMARY_STAGES = Object.freeze([
  "incoming",
  "verify",
  "resolve",
  "ready",
]);

export const SUPPLY_INTAKE_LIFECYCLE_STATUSES = Object.freeze([
  "active",
  "published",
  "rejected",
  "expired",
  "cancelled",
  "taken_down",
]);

export const SUPPLY_INTAKE_LIFECYCLE_SEMANTICS = Object.freeze({
  activeStatuses: Object.freeze(["active"]),
  publishedStatuses: Object.freeze(["published"]),
  expiredStatuses: Object.freeze(["expired"]),
});

export const SUPPLY_INTAKE_ENTITY_KINDS = Object.freeze([
  "event",
  "organizer",
  "source_result",
  "source_profile",
]);

export const SUPPLY_INTAKE_TRANSITIONS = Object.freeze({
  incoming: Object.freeze(["verify", "resolve", "ready"]),
  verify: Object.freeze(["resolve", "ready"]),
  resolve: Object.freeze(["verify", "ready"]),
  ready: Object.freeze(["resolve"]),
});
