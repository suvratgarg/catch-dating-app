import type {CaptureRecord} from "../../shared/ui/primitives";

export const captures: Record<string, CaptureRecord> = {
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
