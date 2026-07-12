import {activeFeaturedCity} from "@content/markets";

export type HostApplicationStep = "profile" | "event" | "policy" | "success" | "review";

export interface HostApplicationDraft {
  fullName: string;
  email: string;
  city: string;
  customCity: string;
  organizationName: string;
  organizationType: string;
  communityLink: string;
  formats: string[];
  eventCadence: string;
  nextEventName: string;
  nextEventDate: string;
  eventLocation: string;
  expectedCapacity: string;
  priceRange: string;
  admissionModel: string;
  waitlistPlan: string;
  paymentReadiness: string;
  eventSuccessModules: string[];
  hostGoals: string;
  operatingNotes: string;
}

export const hostApplicationSteps: Array<{
  id: HostApplicationStep;
  label: string;
  body: string;
}> = [
  {
    id: "profile",
    label: "Host profile",
    body: "Who you are, what you run, and where Catch should place the operating profile.",
  },
  {
    id: "event",
    label: "Event draft",
    body: "The first event you want to publish, with enough detail for a real setup review.",
  },
  {
    id: "policy",
    label: "Admission",
    body: "Capacity, pricing, approval, waitlists, and payment readiness.",
  },
  {
    id: "success",
    label: "Run of show",
    body: "Event Success modules you want live at the door, during the room, and after.",
  },
  {
    id: "review",
    label: "Submit",
    body: "Catch receives the operating packet, not just an email address.",
  },
];

export const hostFormatOptions = [
  "Dinner",
  "Singles mixer",
  "Social run",
  "Padel or pickleball",
  "Pub quiz",
  "Bar crawl",
  "Community meetup",
  "Custom format",
];

export const hostSuccessModuleOptions = [
  "Booking balance preview",
  "Attendance and live roster",
  "Welcome script",
  "Starter groups",
  "Timed partner rotations",
  "Host introduction help",
  "Private catch window",
  "Verified attendee reviews",
  "Post-event report",
];

export const initialHostApplicationDraft: HostApplicationDraft = {
  fullName: "",
  email: "",
  city: activeFeaturedCity.label,
  customCity: "",
  organizationName: "",
  organizationType: "Independent host",
  communityLink: "",
  formats: ["Dinner"],
  eventCadence: "Monthly",
  nextEventName: "",
  nextEventDate: "",
  eventLocation: "",
  expectedCapacity: "20",
  priceRange: "₹1,000–₹2,000",
  admissionModel: "Request to join",
  waitlistPlan: "Ranked timed offers",
  paymentReadiness: "Need Catch payment onboarding",
  eventSuccessModules: [
    "Attendance and live roster",
    "Welcome script",
    "Private catch window",
  ],
  hostGoals: "",
  operatingNotes: "",
};

export function hostApplicationStepIsComplete(
  step: HostApplicationStep,
  draft: HostApplicationDraft
): boolean {
  if (step === "profile") {
    return Boolean(
      draft.fullName.trim() &&
      draft.email.trim() &&
      (draft.city !== "Other" || draft.customCity.trim()) &&
      draft.organizationName.trim() &&
      draft.communityLink.trim()
    );
  }
  if (step === "event") {
    return Boolean(
      draft.formats.length &&
      draft.nextEventName.trim() &&
      draft.eventLocation.trim()
    );
  }
  if (step === "policy") {
    return Boolean(
      draft.expectedCapacity.trim() &&
      draft.priceRange.trim() &&
      draft.admissionModel &&
      draft.waitlistPlan &&
      draft.paymentReadiness
    );
  }
  if (step === "success") {
    return Boolean(draft.eventSuccessModules.length && draft.hostGoals.trim());
  }
  return hostApplicationIsComplete(draft);
}

export function hostApplicationStepError(step: HostApplicationStep) {
  switch (step) {
    case "profile":
      return "Add your identity, organizer name, city, and public link.";
    case "event":
      return "Choose at least one format and describe the first event and location.";
    case "policy":
      return "Add capacity, pricing, admission, waitlist, and payment readiness.";
    case "success":
      return "Choose at least one Event Success module and add your host goal.";
    case "review":
      return "Finish the required fields before submitting.";
  }
}

export function hostApplicationIsComplete(draft: HostApplicationDraft): boolean {
  return hostApplicationSteps
    .filter((item) => item.id !== "review")
    .every((item) => hostApplicationStepIsComplete(item.id, draft));
}

export function hostApplicationCompleteness(draft: HostApplicationDraft) {
  const checklist = hostApplicationChecklist(draft);
  const completed = checklist.filter((item) => item.done).length;
  return Math.round((completed / checklist.length) * 100);
}

export function hostApplicationChecklist(draft: HostApplicationDraft) {
  return [
    {
      label: "Host identity and public link",
      done: hostApplicationStepIsComplete("profile", draft),
    },
    {
      label: "First event draft",
      done: hostApplicationStepIsComplete("event", draft),
    },
    {
      label: "Admission and payment policy",
      done: hostApplicationStepIsComplete("policy", draft),
    },
    {
      label: "Event Success setup",
      done: hostApplicationStepIsComplete("success", draft),
    },
  ];
}
