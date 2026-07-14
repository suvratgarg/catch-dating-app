import type {CaptureRecord} from "../../shared/ui/primitives";

export const captures: Record<string, CaptureRecord> = {
  "host-create-basics": capture(
    "host-create-basics",
    "Basics",
    "Name the format, city, and first organizer details before the event rules appear."
  ),
  "host-create-location": capture(
    "host-create-location",
    "Location",
    "Set the venue, precise meeting point, and arrival note guests will see."
  ),
  "host-create-schedule": capture(
    "host-create-schedule",
    "Schedule",
    "Place the event into the host calendar with date, start time, and check-in timing."
  ),
  "host-create-policy": capture(
    "host-create-policy",
    "Policy",
    "Balance capacity, pricing, admission, waitlists, cohorts, and cancellation rules."
  ),
  "host-create-guide": capture(
    "host-create-guide",
    "Live guide",
    "Choose the live Event Success guide before the night starts."
  ),
  "host-event-setup": capture(
    "host-event-setup",
    "Host event setup",
    "Create event setup in the Catch host app"
  ),
  "host-live-console": capture(
    "host-live-console",
    "Host live console",
    "Live roster, check-in, and Event Success controls"
  ),
  "host-post-event-report": capture(
    "host-post-event-report",
    "Host post-event report",
    "Post-event report with attendance and follow-up signals"
  ),
  "match-chat-context": capture(
    "match-chat-context",
    "Match chat",
    "Match chat with shared event context"
  ),
  "member-event-discovery": capture(
    "member-event-discovery",
    "Member event discovery",
    "Hosted event discovery in the Catch member app"
  ),
  "post-run-catch-window": capture(
    "post-run-catch-window",
    "Post-run catch window",
    "Private post-event catch window"
  ),
};

export const placeholderCaptures: Record<string, CaptureRecord> = {};

function capture(id: string, walkthroughStep: string, caption: string): CaptureRecord {
  return {
    id,
    webPath: `/assets/app-screenshots/${id}.png`,
    alt: caption,
    caption,
    walkthroughStep,
  };
}
