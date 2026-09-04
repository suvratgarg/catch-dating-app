import {HttpsError} from "firebase-functions/v2/https";
import {
  EventAttendeeDocument,
  EventRehearsalActorDocument,
  EventRehearsalDocument,
} from "../shared/generated/firestoreAdminTypes";
import {requireDoc} from "../shared/validation";
import {buildRehearsalActors, REHEARSAL_MAX_ACTORS} from "./engine";

type RosterSnapshot = NonNullable<EventRehearsalDocument["rosterSnapshot"]>;

/** Reads the roster once, retaining only names and attendance. */
export async function loadRehearsalRosterSnapshot(
  db: FirebaseFirestore.Firestore,
  eventId: string,
  organizerId: string,
): Promise<RosterSnapshot> {
  // firestore-index: eventAttendees (eventId:ASCENDING, status:ASCENDING)
  const snapshot = await db
    .collection("eventAttendees")
    .where("eventId", "==", eventId)
    .where("status", "in", ["registered", "checkedIn"])
    .limit(REHEARSAL_MAX_ACTORS + 1)
    .get();
  const roster = snapshot.docs
    .sort((a, b) => a.id.localeCompare(b.id))
    .map((doc) => {
      const attendee = requireDoc<EventAttendeeDocument>(
        doc,
        "EventAttendeeDocument",
      );
      if (
        attendee.organizerId !== organizerId ||
        attendee.eventId !== eventId
      ) {
        throw new HttpsError(
          "permission-denied",
          "Roster organizer mismatch.",
        );
      }
      return {
        displayName: attendee.displayName,
        status:
          attendee.status === "checkedIn" ?
            ("present" as const) :
            ("expected" as const),
      };
    });
  if (roster.length < 2 || roster.length > REHEARSAL_MAX_ACTORS) {
    throw new HttpsError(
      "failed-precondition",
      "This event needs between 2 and 50 registered guests to copy. " +
        "Choose simulated guests in Customise rehearsal.",
    );
  }
  return roster;
}

/** Every practice identity is newly scoped, including copied event guests. */
export function buildConfiguredRehearsalActors(
  sessionId: string,
  actorCount: number,
  seed: number,
  now: FirebaseFirestore.Timestamp,
  roster?: RosterSnapshot,
  setup?: EventRehearsalDocument["setup"],
): EventRehearsalActorDocument[] {
  return buildRehearsalActors(
    sessionId,
    roster?.length ?? actorCount,
    seed,
    now,
  ).map((actor, index) => {
    const source = roster?.[index];
    const placed = {
      ...actor,
      layoutUnitId: `table-${
        Math.floor(
          index / rehearsalUnitSize(roster?.length ?? actorCount, setup),
        ) + 1
      }`,
    };
    return source ?
      {
        ...placed,
        displayName: source.displayName,
        status: source.status,
        persona: "regular",
      } :
      placed;
  });
}

export function rehearsalUnitSize(
  actorCount: number,
  setup?: EventRehearsalDocument["setup"],
): number {
  const structure = setup?.successDefaults?.structureConfig;
  return structure?.unitKind === "wholeGroup" ?
    Math.max(1, actorCount) :
    Math.max(
      1,
      typeof structure?.unitSize === "number" ? structure.unitSize : 4,
    );
}

export function rehearsalUnitCount(
  session: EventRehearsalDocument,
): number {
  return Math.max(
    1,
    Number(session.setup.successDefaults?.structureConfig?.unitCount ?? 0),
    Math.ceil(
      session.actorCount /
        rehearsalUnitSize(session.actorCount, session.setup),
    ),
  );
}

/** Production layout references and arbitrary activity metadata stay out. */
export function freezeRehearsalSetup(
  setup: EventRehearsalDocument["setup"],
): EventRehearsalDocument["setup"] {
  const format = setup.eventFormat;
  const safeFormat = format ?
    {
      version: format.version,
      activityKind: format.activityKind,
      interactionModel: format.interactionModel,
      ...(format.customActivityLabel ?
        {customActivityLabel: format.customActivityLabel} :
        {}),
      ...(format.defaultPlaybookId ?
        {defaultPlaybookId: format.defaultPlaybookId} :
        {}),
      ...(format.defaultModuleIds ?
        {defaultModuleIds: format.defaultModuleIds} :
        {}),
      ...(format.eventSuccessPrimitives ?
        {eventSuccessPrimitives: format.eventSuccessPrimitives} :
        {}),
    } :
    undefined;
  return {
    ...setup,
    ...(safeFormat ? {eventFormat: safeFormat} : {}),
    ...(setup.successDefaults ?
      {
        successDefaults: {...setup.successDefaults, layoutId: null},
      } :
      {}),
  };
}
