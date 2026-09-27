export const READ_ACTIONS = [
  "hosts.search", "hosts.get", "tasks.list", "opportunities.list",
  "fields.list", "receipts.get",
] as const;
export const WRITE_ACTIONS = [
  "activities.log", "tasks.upsert", "opportunities.upsert",
  "fields.create", "fields.setValue", "evidence.propose",
] as const;
export const ASSISTANT_ACTIONS: readonly string[] =
  [...READ_ACTIONS, ...WRITE_ACTIONS];
