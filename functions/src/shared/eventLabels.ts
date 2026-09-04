import type {
  EventDocument,
  EventFormatSnapshot,
} from "./generated/firestoreAdminTypes";

const activityLabels: Record<EventFormatSnapshot["activityKind"], string> = {
  socialRun: "Social run",
  running: "Running",
  walking: "Walking",
  pickleball: "Pickleball",
  padel: "Padel",
  tennis: "Tennis",
  badminton: "Badminton",
  cycling: "Cycling",
  spinClass: "Spin class",
  yoga: "Yoga",
  strengthTraining: "Strength training",
  pubQuiz: "Pub quiz",
  barCrawl: "Bar crawl",
  dinner: "Dinner",
  singlesMixer: "Singles mixer",
  openActivity: "Open activity",
};

/** Returns the reader-facing event format label used by server projections. */
export function eventFormatLabel(format: EventFormatSnapshot): string {
  return format.customActivityLabel?.trim() ||
    activityLabels[format.activityKind] ||
    humanizeToken(format.activityKind);
}

/** Returns a compact title derived from canonical event format data. */
export function eventTitleLabel(event: EventDocument): string {
  return eventFormatLabel(event.eventFormat);
}

function humanizeToken(value: string): string {
  const words = value.replace(/([a-z])([A-Z])/g, "$1 $2");
  return words.charAt(0).toUpperCase() + words.slice(1).toLowerCase();
}
