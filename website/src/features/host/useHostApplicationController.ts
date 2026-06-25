import {type FormEvent, useState} from "react";
import {
  createMarketingEventId,
  trackMarketingEvent,
  waitlistAnalyticsPayload,
} from "../../analytics";
import type {FormStatus} from "../../shared/forms/types";
import {
  hostApplicationIsComplete,
  hostApplicationStepError,
  hostApplicationStepIsComplete,
  hostApplicationSteps,
  initialHostApplicationDraft,
  type HostApplicationDraft,
  type HostApplicationStep,
} from "./applicationModel";

export function useHostApplicationController() {
  const [draft, setDraft] = useState<HostApplicationDraft>(initialHostApplicationDraft);
  const [step, setStep] = useState<HostApplicationStep>("profile");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [hasStarted, setHasStarted] = useState(false);
  const [submitted, setSubmitted] = useState(false);
  const [status, setStatus] = useState<FormStatus>({message: "", tone: ""});

  const currentStepIndex = hostApplicationSteps.findIndex((item) => item.id === step);
  const resolvedCity = draft.city === "Other" ? draft.customCity.trim() : draft.city;
  const canContinue = hostApplicationStepIsComplete(step, draft);

  function updateDraft<K extends keyof HostApplicationDraft>(
    key: K,
    value: HostApplicationDraft[K]
  ) {
    setDraft((current) => ({...current, [key]: value}));
  }

  function toggleDraftList(key: "formats" | "eventSuccessModules", value: string) {
    setDraft((current) => {
      const values = current[key];
      const next = values.includes(value)
        ? values.filter((item) => item !== value)
        : [...values, value];
      return {...current, [key]: next};
    });
  }

  function handleFormStart() {
    if (hasStarted) return;
    setHasStarted(true);
    trackMarketingEvent("host_operating_application_started", {
      form_variant: "host",
    });
  }

  function goToStep(nextStep: HostApplicationStep) {
    setStep(nextStep);
  }

  function goNext() {
    if (!canContinue) {
      setStatus({
        message: hostApplicationStepError(step),
        tone: "is-error",
      });
      return;
    }
    const next = hostApplicationSteps[currentStepIndex + 1];
    if (next) {
      setStatus({message: "", tone: ""});
      setStep(next.id);
    }
  }

  function goBack() {
    const previous = hostApplicationSteps[currentStepIndex - 1];
    if (previous) setStep(previous.id);
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!hostApplicationIsComplete(draft)) {
      setStatus({
        message: "Finish the required profile, event, and operating fields before submitting.",
        tone: "is-error",
      });
      return;
    }

    const eventId = createMarketingEventId("host_lead");
    const conversionPayload = waitlistAnalyticsPayload(eventId, "host");
    const body = {
      fullName: draft.fullName.trim(),
      email: draft.email.trim(),
      city: resolvedCity,
      role: "host",
      instagram: draft.communityLink.trim(),
      website: "",
      hostApplication: {
        organizationName: draft.organizationName.trim(),
        organizationType: draft.organizationType,
        operatingCity: resolvedCity,
        communityLink: draft.communityLink.trim(),
        formats: draft.formats,
        eventCadence: draft.eventCadence,
        nextEventName: draft.nextEventName.trim(),
        nextEventDate: draft.nextEventDate,
        eventLocation: draft.eventLocation.trim(),
        expectedCapacity: draft.expectedCapacity,
        priceRange: draft.priceRange,
        admissionModel: draft.admissionModel,
        waitlistPlan: draft.waitlistPlan,
        paymentReadiness: draft.paymentReadiness,
        eventSuccessModules: draft.eventSuccessModules,
        hostGoals: draft.hostGoals.trim(),
        operatingNotes: draft.operatingNotes.trim(),
      },
      ...conversionPayload,
    };

    setIsSubmitting(true);
    setStatus({message: "", tone: ""});
    trackMarketingEvent("host_operating_application_submit_attempt", {
      city: body.city,
      event_id: eventId,
      format_count: draft.formats.length,
      module_count: draft.eventSuccessModules.length,
    });

    try {
      const response = await fetch("/api/join-waitlist", {
        method: "POST",
        headers: {"Content-Type": "application/json"},
        body: JSON.stringify(body),
      });
      const data = (await response.json().catch(() => ({}))) as {
        alreadyJoined?: boolean;
        error?: string;
      };

      if (!response.ok) {
        throw new Error(
          typeof data.error === "string"
            ? data.error
            : "We couldn't submit the host application. Please try again."
        );
      }

      setSubmitted(true);
      setStatus({
        message: data.alreadyJoined
          ? "Application updated. Catch refreshed your operating packet."
          : "Application submitted. Catch will review the host packet before onboarding.",
        tone: "is-success",
      });
      trackMarketingEvent("host_operating_application_submitted", {
        already_joined: Boolean(data.alreadyJoined),
        city: body.city,
        event_id: eventId,
        format_count: draft.formats.length,
        module_count: draft.eventSuccessModules.length,
      });
      trackMarketingEvent("generate_lead", {
        city: body.city,
        event_id: eventId,
        form_variant: "host",
        lead_type: "host",
      });
    } catch (error) {
      setStatus({
        message:
          error instanceof Error ?
            error.message :
            "We couldn't submit the host application. Please try again.",
        tone: "is-error",
      });
      trackMarketingEvent("host_operating_application_submit_error", {
        event_id: eventId,
      });
    } finally {
      setIsSubmitting(false);
    }
  }

  return {
    canContinue,
    currentStepIndex,
    draft,
    goBack,
    goNext,
    goToStep,
    handleFormStart,
    handleSubmit,
    isSubmitting,
    resolvedCity,
    status,
    step,
    submitted,
    toggleDraftList,
    updateDraft,
  };
}
