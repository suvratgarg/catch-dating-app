

export function fallbackCaptionForCapture(id: string) {
  switch (id) {
    case "member-event-discovery":
      return "Members browse real hosted events before any dating surface opens.";
    case "post-run-catch-window":
      return "The roster opens after attendance creates shared context.";
    case "match-chat-context":
      return "Matches start with the event they already shared.";
    case "host-event-setup":
      return "Set admission rules, invite links, waitlist, payments, and Playbook before publishing.";
    case "host-live-console":
      return "Check in guests, manage waitlist movement, and run Playbook modules from one screen.";
    case "host-post-event-report":
      return "Review invite conversion, waitlist movement, attendance, catches, matches, and chats after the event closes.";
    default:
      return "Catch app screen for members and hosts.";
  }
}
