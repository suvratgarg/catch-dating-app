import {useMutation} from "@tanstack/react-query";
import {type FormEvent, useCallback, useEffect, useId, useMemo, useRef, useState} from "react";
import type {User} from "../../firebase";
import {
  beginPublicEventPhoneVerification,
  checkInEventRuntime,
  claimEventRuntimeAccess,
  completeEventRuntimeFirstHello,
  createEventRuntimeAttendeeInviteLink,
  fetchEventRuntimeWingmanCandidates,
  getEventRuntimeBootstrap,
  heartbeatEventRuntimePresence,
  recordEventInviteLinkOpen,
  recordEventRuntimeShareIntent,
  saveEventRuntimeCompatibilityAnswers,
  saveEventRuntimeFeedback,
  startEventRuntimeFirstHello,
  submitEventRuntimeProfile,
  submitEventRuntimeWingmanRequest,
  watchEventRuntimeAuthState,
  watchEventRuntimeLiveState,
  withdrawEventRuntimeWingmanRequest,
  type EventRuntimeLiveState,
  type EventRuntimeAttendeeInviteLink,
  type PublicEventPhoneVerification,
} from "../../firebase";
import {eventRuntimeCopy} from "../../content/eventRuntime";
import type {FormStatus} from "../../shared/forms/types";
import {
  eventRuntimeError,
  eventRuntimeStageForParticipant,
  normalizeRuntimePhone,
  resolveEventRuntimeQuestionnaire,
  type EventRuntimeBootstrap,
  type EventRuntimeGender,
} from "./eventRuntimeModel";
import {eventInviteSessionId, eventInviteTokenFromLocation} from
  "../../shared/eventInviteAttribution";

export type EventRuntimeStage =
  | "loading"
  | "phone"
  | "otp"
  | "profile"
  | "approval"
  | "runtime"
  | "unavailable";

export interface WingmanCandidate {
  uid: string;
  displayName: string;
  gender: EventRuntimeGender | null;
}

const emptyLiveState: EventRuntimeLiveState = {
  assignments: [],
  compatibilityAnswerIds: [],
  feedback: null,
  mission: null,
  lateArrival: null,
  plan: null,
  standings: null,
  wingmanTargetUid: null,
};

export function useEventRuntimeController(publicRuntimeId: string) {
  const reactId = useId();
  const recaptchaContainerId = `event-runtime-recaptcha-${reactId.replace(/:/gu, "")}`;
  const verificationRef = useRef<PublicEventPhoneVerification | null>(null);
  const userRef = useRef<User | null>(null);
  const loadingRef = useRef<Promise<void> | null>(null);
  const attendeeLinkEventIdRef = useRef<string | null>(null);
  const [user, setUser] = useState<User | null>(null);
  const [bootstrap, setBootstrap] = useState<EventRuntimeBootstrap | null>(null);
  const [stage, setStage] = useState<EventRuntimeStage>("loading");
  const [status, setStatus] = useState<FormStatus>({message: "", tone: ""});
  const [phoneNumber, setPhoneNumber] = useState("");
  const [code, setCode] = useState("");
  const [displayName, setDisplayName] = useState("");
  const [gender, setGender] = useState<EventRuntimeGender | null>(null);
  const [interestedInGenders, setInterestedInGenders] = useState<EventRuntimeGender[]>([]);
  const [preferenceProfileEnabled, setPreferenceProfileEnabled] = useState(false);
  const [sensitiveConsent, setSensitiveConsent] = useState(false);
  const [saveAsCatchPrefill, setSaveAsCatchPrefill] = useState(false);
  const [liveState, setLiveState] = useState<EventRuntimeLiveState>(emptyLiveState);
  const [questionAnswers, setQuestionAnswers] = useState<Record<string, string>>({});
  const [wingmanCandidates, setWingmanCandidates] = useState<WingmanCandidate[]>([]);
  const [wingmanTargetUid, setWingmanTargetUid] = useState("");
  const [welcomeRating, setWelcomeRating] = useState(4);
  const [structureRating, setStructureRating] = useState(4);
  const [metNewPeopleCount, setMetNewPeopleCount] = useState(2);
  const [safetyConcern, setSafetyConcern] = useState(false);
  const [privateNote, setPrivateNote] = useState("");
  const actionMutation = useMutation<void, unknown, () => Promise<void>>({
    mutationFn: (action) => action(),
    onError: (error) => {
      setStatus({message: eventRuntimeError(error), tone: "is-error"});
    },
  });
  const attendeeLinkMutation = useMutation<
    EventRuntimeAttendeeInviteLink,
    unknown,
    string
  >({
    mutationFn: (eventId) => createEventRuntimeAttendeeInviteLink(
      eventId,
      eventRuntimeCopy.shareLinkLabel
    ),
    onError: (error) => {
      setStatus({message: eventRuntimeError(error), tone: "is-error"});
    },
  });
  const pending = actionMutation.isPending;
  const attendeeInviteLink = attendeeLinkMutation.data ?? null;
  const inviteToken = useMemo(eventInviteTokenFromLocation, []);
  const recordedInviteOpenRef = useRef(false);

  const questionnaire = useMemo(
    () => resolveEventRuntimeQuestionnaire(bootstrap?.event.questionnaireConfig ?? null),
    [bootstrap]
  );
  const offersPreferenceProfile = Boolean(
    bootstrap?.event.optionalFieldIds.includes("gender") &&
    bootstrap.event.optionalFieldIds.includes("interestedInGenders")
  );

  const loadAuthenticatedRuntime = useCallback(async (activeUser: User) => {
    if (loadingRef.current) return loadingRef.current;
    const request = (async () => {
      try {
        let next = await getEventRuntimeBootstrap({publicRuntimeId});
        setBootstrap(next);
        hydrateProfile(next);
        const nextStage = eventRuntimeStageForParticipant(next.participant);
        if (nextStage === "runtime" && next.participant?.attendanceStatus !== "checkedIn") {
          await checkInEventRuntime({publicRuntimeId});
          next = await getEventRuntimeBootstrap({publicRuntimeId});
          setBootstrap(next);
          hydrateProfile(next);
        }
        if (userRef.current?.uid === activeUser.uid) setStage(nextStage);
      } catch (error) {
        setStatus({message: eventRuntimeError(error), tone: "is-error"});
        setStage("unavailable");
      }
    })();
    loadingRef.current = request;
    try {
      await request;
    } finally {
      if (loadingRef.current === request) loadingRef.current = null;
    }
  }, [publicRuntimeId]);

  useEffect(() => {
    let cancelled = false;
    void getEventRuntimeBootstrap({publicRuntimeId})
      .then((next) => {
        if (cancelled) return;
        setBootstrap(next);
        if (inviteToken && !recordedInviteOpenRef.current) {
          recordedInviteOpenRef.current = true;
          void recordEventInviteLinkOpen({
            eventId: next.event.eventId,
            inviteLinkId: inviteToken,
            surface: "runtimeWeb",
            sessionId: eventInviteSessionId(),
          }).catch(() => undefined);
        }
        if (!userRef.current) setStage("phone");
      })
      .catch((error) => {
        if (cancelled) return;
        setStatus({message: eventRuntimeError(error), tone: "is-error"});
        setStage("unavailable");
      });
    const unsubscribe = watchEventRuntimeAuthState((nextUser) => {
      if (cancelled) return;
      userRef.current = nextUser;
      setUser(nextUser);
      if (nextUser) {
        setStage("loading");
        void loadAuthenticatedRuntime(nextUser);
      }
    });
    return () => {
      cancelled = true;
      verificationRef.current?.clear();
      unsubscribe();
    };
  }, [inviteToken, loadAuthenticatedRuntime, publicRuntimeId]);

  useEffect(() => {
    const participant = bootstrap?.participant;
    if (stage !== "runtime" || !participant || !user) return undefined;
    let disposed = false;
    let unsubscribe: () => void = () => undefined;
    void watchEventRuntimeLiveState({
      eventId: participant.eventId,
      clubId: participant.clubId,
      organizerId: participant.organizerId,
      uid: user.uid,
    }, (next) => {
      if (disposed) return;
      setLiveState(next);
      setWingmanTargetUid(next.wingmanTargetUid ?? "");
      if (next.feedback) {
        setWelcomeRating(next.feedback.welcomeRating);
        setStructureRating(next.feedback.structureRating);
        setMetNewPeopleCount(next.feedback.metNewPeopleCount);
        setSafetyConcern(next.feedback.safetyConcern);
        setPrivateNote(next.feedback.privateNote ?? "");
      }
      setQuestionAnswers((current) => answerMapForIds(
        questionnaire.questions,
        next.compatibilityAnswerIds,
        current
      ));
    }, (error) => {
      if (!disposed) setStatus({message: eventRuntimeError(error), tone: "is-error"});
    }).then((stop) => {
      if (disposed) stop();
      else unsubscribe = stop;
    }).catch((error) => {
      if (!disposed) setStatus({message: eventRuntimeError(error), tone: "is-error"});
    });
    if (bootstrap.event.moduleIds.includes("wingman_requests")) {
      void fetchEventRuntimeWingmanCandidates({eventId: participant.eventId})
        .then((response) => {
          if (!disposed) setWingmanCandidates(response.candidates ?? []);
        })
        .catch(() => setWingmanCandidates([]));
    }
    return () => {
      disposed = true;
      unsubscribe();
    };
  }, [bootstrap, questionnaire.questions, stage, user]);

  useEffect(() => {
    const participant = bootstrap?.participant;
    if (
      stage !== "runtime" ||
      participant?.attendanceStatus !== "checkedIn" ||
      !bootstrap ||
      Date.now() > bootstrap.event.endTimeMillis
    ) return undefined;
    let disposed = false;
    let timer: ReturnType<typeof setTimeout> | undefined;
    const sendHeartbeat = async () => {
      if (Date.now() > bootstrap.event.endTimeMillis) return;
      try {
        const response = await heartbeatEventRuntimePresence(
          participant.eventId
        );
        if (!disposed) {
          timer = setTimeout(
            sendHeartbeat,
            response.heartbeatIntervalSeconds * 1000
          );
        }
      } catch {
        if (!disposed) timer = setTimeout(sendHeartbeat, 10_000);
      }
    };
    void sendHeartbeat();
    return () => {
      disposed = true;
      if (timer !== undefined) clearTimeout(timer);
    };
  }, [bootstrap, stage]);

  useEffect(() => {
    const participant = bootstrap?.participant;
    if (stage !== "runtime" || !participant || attendeeInviteLink ||
        attendeeLinkEventIdRef.current === participant.eventId) return;
    attendeeLinkEventIdRef.current = participant.eventId;
    attendeeLinkMutation.mutate(participant.eventId);
  }, [
    attendeeInviteLink,
    attendeeLinkMutation,
    bootstrap?.participant,
    stage,
  ]);

  async function handlePhoneSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (pending) return;
    const phone = normalizeRuntimePhone(phoneNumber);
    if (!/^\+[1-9][0-9]{7,14}$/u.test(phone)) {
      setStatus({message: eventRuntimeCopy.invalidPhone, tone: "is-error"});
      return;
    }
    setStatus({message: "", tone: ""});
    await actionMutation.mutateAsync(async () => {
      verificationRef.current?.clear();
      verificationRef.current = await beginPublicEventPhoneVerification(
        phone,
        recaptchaContainerId
      );
      setStage("otp");
    }).catch(() => undefined);
  }

  async function handleCodeSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (pending) return;
    if (!/^[0-9]{6}$/u.test(code.trim())) {
      setStatus({message: eventRuntimeCopy.invalidCode, tone: "is-error"});
      return;
    }
    const verification = verificationRef.current;
    if (!verification) {
      setStage("phone");
      setStatus({message: eventRuntimeCopy.verificationExpired, tone: "is-error"});
      return;
    }
    setStatus({message: "", tone: ""});
    await actionMutation.mutateAsync(async () => {
      const verifiedUser = await verification.confirm(code.trim());
      verification.clear();
      verificationRef.current = null;
      userRef.current = verifiedUser;
      setUser(verifiedUser);
      setStage("loading");
      await loadAuthenticatedRuntime(verifiedUser);
    }).catch(() => undefined);
  }

  async function handleProfileSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (pending || !bootstrap || !user) return;
    const name = displayName.trim();
    if (!name) {
      setStatus({message: eventRuntimeCopy.missingName, tone: "is-error"});
      return;
    }
    if (preferenceProfileEnabled && interestedInGenders.length === 0) {
      setStatus({message: eventRuntimeCopy.missingInterests, tone: "is-error"});
      return;
    }
    if (preferenceProfileEnabled && (!gender || !sensitiveConsent)) {
      setStatus({message: eventRuntimeCopy.missingSensitiveConsent, tone: "is-error"});
      return;
    }
    setStatus({message: "", tone: ""});
    await actionMutation.mutateAsync(async () => {
      let accessStatus = bootstrap.participant?.accessStatus ?? "needsClaim";
      if (!bootstrap.participant || accessStatus === "needsClaim") {
        const claim = await claimEventRuntimeAccess({
          publicRuntimeId,
          displayName: name,
          runtimeTermsVersion: bootstrap.event.runtimeTermsVersion,
          inviteToken,
        });
        accessStatus = claim.status;
      }
      if (accessStatus === "pendingApproval") {
        await loadAuthenticatedRuntime(user);
        return;
      }
      await submitEventRuntimeProfile({
        publicRuntimeId,
        runtimeTermsVersion: bootstrap.event.runtimeTermsVersion,
        sensitiveDataTermsVersion: preferenceProfileEnabled ?
          "event-runtime-sensitive-v1" : null,
        saveAsCatchPrefill,
        fields: {
          displayName: name,
          gender: preferenceProfileEnabled ? gender : null,
          interestedInGenders: preferenceProfileEnabled ?
            interestedInGenders : [],
          relationshipGoal: preferenceProfileEnabled ? undefined : null,
          dateOfBirthMillis: preferenceProfileEnabled ? undefined : null,
        },
      });
      await loadAuthenticatedRuntime(user);
    }).catch(() => undefined);
  }

  async function handleRefresh() {
    if (!user || pending) return;
    setStatus({message: "", tone: ""});
    await actionMutation.mutateAsync(async () => {
      await loadAuthenticatedRuntime(user);
    }).catch(() => undefined);
  }

  async function shareEvent() {
    const participant = bootstrap?.participant;
    if (!participant || pending) return;
    setStatus({message: "", tone: ""});
    const link = attendeeInviteLink;
    if (!link) {
      setStatus({message: eventRuntimeCopy.shareNotReady, tone: ""});
      return;
    }
    const shareUrl = new URL(
      `/invite/${encodeURIComponent(link.inviteToken)}`,
      window.location.origin
    ).toString();
    const shareData = {
      title: bootstrap.event.title,
      text: eventRuntimeCopy.shareText(bootstrap.event.title),
      url: shareUrl,
    };
    if (typeof navigator.share === "function") {
      void recordEventRuntimeShareIntent({
        eventId: participant.eventId,
        inviteLinkId: link.inviteLinkId,
        channelHint: "systemShare",
      }).catch(() => undefined);
      try {
        await navigator.share(shareData);
        setStatus({message: eventRuntimeCopy.shareOpened, tone: "is-success"});
      } catch (error) {
        if (error instanceof DOMException && error.name === "AbortError") {
          setStatus({message: eventRuntimeCopy.shareCancelled, tone: ""});
          return;
        }
        setStatus({message: eventRuntimeError(error), tone: "is-error"});
      }
      return;
    }
    if (navigator.clipboard?.writeText) {
      try {
        await navigator.clipboard.writeText(shareUrl);
      } catch (error) {
        setStatus({message: eventRuntimeError(error), tone: "is-error"});
        return;
      }
      void recordEventRuntimeShareIntent({
        eventId: participant.eventId,
        inviteLinkId: link.inviteLinkId,
        channelHint: "copyLink",
      }).catch(() => undefined);
      setStatus({message: eventRuntimeCopy.shareCopied, tone: "is-success"});
      return;
    }
    setStatus({message: eventRuntimeCopy.shareManual(shareUrl), tone: ""});
  }

  function retryAttendeeInviteLink() {
    const participant = bootstrap?.participant;
    if (!participant || attendeeLinkMutation.isPending || attendeeInviteLink) return;
    setStatus({message: "", tone: ""});
    attendeeLinkMutation.mutate(participant.eventId);
  }

  function toggleInterest(nextGender: EventRuntimeGender) {
    if (pending) return;
    setInterestedInGenders((current) => current.includes(nextGender) ?
      current.filter((item) => item !== nextGender) : [...current, nextGender]);
  }

  function selectQuestionAnswer(questionId: string, answerId: string) {
    setQuestionAnswers((current) => ({...current, [questionId]: answerId}));
  }

  async function saveCompatibilityAnswers() {
    const participant = bootstrap?.participant;
    if (!participant || !user || pending) return;
    await actionMutation.mutateAsync(async () => {
      await saveEventRuntimeCompatibilityAnswers({
        eventId: participant.eventId,
        clubId: participant.clubId,
        organizerId: participant.organizerId,
        uid: user.uid,
      }, Object.values(questionAnswers));
      setStatus({message: eventRuntimeCopy.compatibilitySaved, tone: "is-success"});
    }).catch(() => undefined);
  }

  async function startFirstHello() {
    const participant = bootstrap?.participant;
    if (!participant || pending) return;
    await actionMutation.mutateAsync(async () => {
      const position = await browserPosition();
      await startEventRuntimeFirstHello({eventId: participant.eventId, ...position});
    }).catch(() => undefined);
  }

  async function completeFirstHello(answerId: string) {
    const participant = bootstrap?.participant;
    if (!participant || pending) return;
    await actionMutation.mutateAsync(async () => {
      const position = await browserPosition();
      await completeEventRuntimeFirstHello({
        eventId: participant.eventId,
        answerId,
        ...position,
      });
    }).catch(() => undefined);
  }

  async function submitWingmanRequest() {
    const participant = bootstrap?.participant;
    if (!participant || !wingmanTargetUid || pending) return;
    await actionMutation.mutateAsync(async () => {
      await submitEventRuntimeWingmanRequest({
        eventId: participant.eventId,
        targetUid: wingmanTargetUid,
      });
    }).catch(() => undefined);
  }

  async function withdrawWingmanRequest() {
    const participant = bootstrap?.participant;
    if (!participant || pending) return;
    await actionMutation.mutateAsync(async () => {
      await withdrawEventRuntimeWingmanRequest({eventId: participant.eventId});
    }).catch(() => undefined);
  }

  async function submitFeedback() {
    const participant = bootstrap?.participant;
    if (!participant || !user || pending) return;
    await actionMutation.mutateAsync(async () => {
      await saveEventRuntimeFeedback({
        eventId: participant.eventId,
        clubId: participant.clubId,
        organizerId: participant.organizerId,
        uid: user.uid,
      }, {
        welcomeRating,
        structureRating,
        metNewPeopleCount,
        safetyConcern,
        privateNote: privateNote.trim() || null,
      });
      setStatus({message: eventRuntimeCopy.feedbackSaved, tone: "is-success"});
    }).catch(() => undefined);
  }

  function hydrateProfile(next: EventRuntimeBootstrap) {
    const profile = next.participant?.runtimeProfile;
    if (!profile) return;
    setDisplayName(profile.displayName);
    setGender(profile.gender);
    setInterestedInGenders(profile.interestedInGenders);
    setPreferenceProfileEnabled(
      profile.gender !== null || profile.interestedInGenders.length > 0
    );
  }

  return {
    bootstrap,
    attendeeInviteLink,
    attendeeInviteLinkLoading: attendeeLinkMutation.isPending,
    code,
    completeFirstHello,
    displayName,
    gender,
    handleCodeSubmit,
    handlePhoneSubmit,
    handleProfileSubmit,
    handleRefresh,
    interestedInGenders,
    liveState,
    metNewPeopleCount,
    pending,
    phoneNumber,
    publicRuntimeId,
    questionnaire,
    questionAnswers,
    recaptchaContainerId,
    retryAttendeeInviteLink,
    offersPreferenceProfile,
    privateNote,
    preferenceProfileEnabled,
    saveAsCatchPrefill,
    saveCompatibilityAnswers,
    shareEvent,
    selectQuestionAnswer,
    sensitiveConsent,
    setCode,
    setDisplayName,
    setGender,
    setPhoneNumber,
    setPreferenceProfileEnabled,
    setMetNewPeopleCount,
    setPrivateNote,
    setSaveAsCatchPrefill,
    setSensitiveConsent,
    setSafetyConcern,
    setStructureRating,
    setWelcomeRating,
    setWingmanTargetUid,
    stage,
    startFirstHello,
    status,
    structureRating,
    submitFeedback,
    submitWingmanRequest,
    toggleInterest,
    safetyConcern,
    welcomeRating,
    wingmanCandidates,
    wingmanTargetUid,
    withdrawWingmanRequest,
  };
}

function answerMapForIds(
  questions: Array<{id: string; options: Array<{id: string}>}>,
  answerIds: string[],
  current: Record<string, string>
): Record<string, string> {
  const next = {...current};
  for (const question of questions) {
    const selected = question.options.find((option) => answerIds.includes(option.id));
    if (selected) next[question.id] = selected.id;
  }
  return next;
}

async function browserPosition(): Promise<{latitude: number | null; longitude: number | null}> {
  if (!("geolocation" in navigator)) return {latitude: null, longitude: null};
  try {
    const position = await new Promise<GeolocationPosition>((resolve, reject) => {
      navigator.geolocation.getCurrentPosition(resolve, reject, {
        enableHighAccuracy: false,
        maximumAge: 60_000,
        timeout: 8_000,
      });
    });
    return {
      latitude: position.coords.latitude,
      longitude: position.coords.longitude,
    };
  } catch {
    return {latitude: null, longitude: null};
  }
}
