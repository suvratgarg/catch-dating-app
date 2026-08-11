import {websiteCopy} from "@content/generated";
import {hostApplicationCopy} from "@content/host";
import {activeFeaturedCity} from "@content/markets";

export type HostApplicationStep = "profile" | "event" | "setup" | "success" | "review";

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
  bookingPlatform: string;
  guestListFormat: string;
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
    label: hostApplicationCopy.steps.profile.label,
    body: hostApplicationCopy.steps.profile.body,
  },
  {
    id: "event",
    label: hostApplicationCopy.steps.event.label,
    body: hostApplicationCopy.steps.event.body,
  },
  {
    id: "setup",
    label: hostApplicationCopy.steps.setup.label,
    body: hostApplicationCopy.steps.setup.body,
  },
  {
    id: "success",
    label: hostApplicationCopy.steps.success.label,
    body: hostApplicationCopy.steps.success.body,
  },
  {
    id: "review",
    label: hostApplicationCopy.steps.review.label,
    body: hostApplicationCopy.steps.review.body,
  },
];

export const hostFormatOptions = [
  websiteCopy["applicationmodel_0178"],
  websiteCopy["applicationmodel_0196"],
  websiteCopy["applicationmodel_0197"],
  websiteCopy["applicationmodel_0189"],
  websiteCopy["applicationmodel_0192"],
  websiteCopy["applicationmodel_0172"],
  websiteCopy["applicationmodel_0176"],
  websiteCopy["applicationmodel_0177"],
];

export const hostSuccessModuleOptions = [...hostApplicationCopy.liveToolOptions];

export const initialHostApplicationDraft: HostApplicationDraft = {
  fullName: "",
  email: "",
  city: activeFeaturedCity.label,
  customCity: "",
  organizationName: "",
  organizationType: websiteCopy["applicationmodel_0186"],
  communityLink: "",
  formats: [websiteCopy["applicationmodel_0178"]],
  eventCadence: websiteCopy["applicationmodel_0187"],
  nextEventName: "",
  nextEventDate: "",
  eventLocation: "",
  expectedCapacity: "20",
  bookingPlatform: hostApplicationCopy.setup.bookingPlatforms[0],
  guestListFormat: hostApplicationCopy.setup.guestListFormats[0],
  eventSuccessModules: [
    hostApplicationCopy.liveToolOptions[0],
    hostApplicationCopy.liveToolOptions[1],
    hostApplicationCopy.liveToolOptions[2],
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
  if (step === "setup") {
    return Boolean(
      draft.expectedCapacity.trim() &&
      draft.bookingPlatform &&
      draft.guestListFormat
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
    case "setup":
      return hostApplicationCopy.errors.setup;
    case "success":
      return "Choose at least one Playbook module and add your host goal.";
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
      label: hostApplicationCopy.checklist.profile,
      done: hostApplicationStepIsComplete("profile", draft),
    },
    {
      label: hostApplicationCopy.checklist.event,
      done: hostApplicationStepIsComplete("event", draft),
    },
    {
      label: hostApplicationCopy.checklist.setup,
      done: hostApplicationStepIsComplete("setup", draft),
    },
    {
      label: hostApplicationCopy.checklist.live,
      done: hostApplicationStepIsComplete("success", draft),
    },
  ];
}
