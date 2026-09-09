import {HttpsError} from "firebase-functions/v2/https";
import {operationContentHash} from "../../operations/durableActions";
import type {EventDocument} from "../../shared/generated/eventDocument";
import type {EventSuccessPlanDocument} from
  "../../shared/generated/eventSuccessPlanDocument";
import type {EventAssistanceGroupProgressDocument as Progress} from
  "../../shared/generated/eventAssistanceGroupProgressDocument";
import type {EventAssistanceGroupProgressCallableResponse as Response} from
  "../../shared/generated/eventAssistanceGroupProgressCallableResponse";

type View = Response["view"];
type Destination = View["destinations"][number];
export type ProgressContext = Progress["context"];
export interface GroupProgressSource {
  context: ProgressContext;
  groupId: string;
  sourceHash: string;
  endAt: number;
  eventOpen: boolean;
  runtimeLive: boolean;
  destinations: Destination[];
}

export function progressIdentity(context: ProgressContext, groupId: string) {
  return "progress:" + operationContentHash([context, groupId]);
}

/** Preserve SDK timestamp precision while hashing only the relevant source. */
export function timestampEvidence(value: unknown) {
  if (!value || typeof value !== "object") throw invalidSource();
  const stamp = value as {seconds?: number; nanoseconds?: number;
    _seconds?: number; _nanoseconds?: number};
  const seconds = stamp.seconds ?? stamp._seconds;
  const nanos = stamp.nanoseconds ?? stamp._nanoseconds;
  if (!Number.isSafeInteger(seconds) || !Number.isInteger(nanos) ||
      nanos! < 0 || nanos! >= 1_000_000_000) throw invalidSource();
  return {_seconds: seconds!, _nanoseconds: nanos!};
}

/** Scheduled stops are possible destinations, never observed movement. */
export function groupProgressSource(params: {
  context: ProgressContext; groupId: string; event: EventDocument;
  plan: EventSuccessPlanDocument | null; eventGeneration: unknown;
  planGeneration: unknown; now: number;
}): GroupProgressSource {
  const {context, groupId, event, plan, now} = params;
  const route = event.eventFormat.activityDetails?.routePlan ?? null;
  const itinerary = event.itinerary ?? [];
  if (new Set(itinerary.map((s) => s.id)).size !== itinerary.length ||
      (route?.paceGroups && new Set(route.paceGroups.map((g) => g.id)).size !==
        route.paceGroups.length)) throw invalidSource();
  const wholeEvent = groupId === "event:whole";
  if (!wholeEvent && (route?.groupStrategy !== "paceGroups" ||
      !route.paceGroups?.some((g) => g.id === groupId))) {
    throw new HttpsError("failed-precondition",
      "This group is not configured.");
  }
  const destinations: Destination[] = [];
  if (wholeEvent && event.meetingLocation) {
    destinations.push({target: {kind: "fixedPlace", placeId: "meeting",
      lateEntry: "allowed"}, label: event.meetingLocation.name,
    location: event.meetingLocation});
  }
  for (const stop of itinerary) {
    if (!stop.location) continue;
    if (wholeEvent && route?.groupStrategy !== "paceGroups") {
      destinations.push({target: {kind: "itineraryStop",
        itineraryId: context.eventId + ":itinerary", stopId: stop.id},
      label: stop.title, location: stop.location});
    } else if (route?.groupStrategy === "paceGroups" && !wholeEvent &&
        route.path && route.path.length >= 2) {
      destinations.push({target: {kind: "groupCheckpoint",
        routeId: context.eventId + ":route", groupId, checkpointId: stop.id},
      label: stop.title, location: stop.location});
    }
  }
  const end = timestampEvidence(event.endTime);
  const endAt = Math.floor(end._seconds * 1000 + end._nanoseconds / 1_000_000);
  const sourceHash = operationContentHash([
    context, groupId, timestampEvidence(params.eventGeneration),
    plan ? timestampEvidence(params.planGeneration) : null,
    timestampEvidence(event.startTime), end,
    event.meetingLocation ?? null, itinerary, route,
  ]);
  return {context, groupId, sourceHash, endAt,
    eventOpen: event.status === "active" && now < endAt &&
      plan?.status !== "complete", runtimeLive: plan?.status === "live",
    destinations};
}

/** Current guidance is derived from confirmed progress and current source. */
export function projectGroupProgress(
  source: GroupProgressSource, progress: Progress | null, now: number
): View {
  const freshness = !progress ? "unconfirmed" :
    progress.sourceHash === source.sourceHash ? "current" : "sourceChanged";
  const destination = progress && source.destinations.find((item) =>
    operationContentHash(item.target) ===
      operationContentHash(progress.destination));
  const guidance = freshness === "current" && destination &&
    source.eventOpen && source.runtimeLive ? {
      revision: progress!.revision, destination: destination.target,
      materialKey: operationContentHash([
        source.sourceHash, destination.target]),
      text: ["Join us at " + destination.location.name + ".",
        destination.location.address, destination.location.notes]
        .filter(Boolean).join("\n"), validUntil: source.endAt,
    } : null;
  return {context: source.context, groupId: source.groupId, serverTime: now,
    revision: progress?.revision ?? 0, sourceHash: source.sourceHash,
    eventOpen: source.eventOpen, runtimeLive: source.runtimeLive,
    freshness, progress, guidance, destinations: source.destinations};
}

export function invalidSource(): HttpsError {
  return new HttpsError("failed-precondition",
    "Event operating information is unavailable. Refresh the event setup.");
}
