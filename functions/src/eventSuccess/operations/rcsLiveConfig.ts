import {defineBoolean} from "firebase-functions/params";

// Stopping submissions must not discard delivery evidence or incoming replies.
export const eventRcsEnabled = defineBoolean("EVENT_ASSISTANCE_RCS_ENABLED",
  {default: false});
export const eventRcsWebhookEnabled = defineBoolean(
  "EVENT_ASSISTANCE_RCS_WEBHOOK_ENABLED", {default: false});
