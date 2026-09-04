import {createHash} from "crypto";
import * as admin from "firebase-admin";
import {onDocumentWritten} from "firebase-functions/v2/firestore";
import type {
  OrganizerFormAggregateDocument,
  OrganizerFormAggregateEventDocument,
  OrganizerFormResponseDocument,
  OrganizerFormVersionDocument,
} from "../shared/generated/firestoreAdminTypes";
import {requireDoc} from "../shared/validation";

type AggregateEventKind = OrganizerFormAggregateEventDocument["eventKind"];
type FormSections = OrganizerFormVersionDocument["definition"]["sections"];
type FormSection = FormSections[number];
type FormQuestion = FormSection["questions"][number];

export interface AggregateDeps {
  firestore: () => FirebaseFirestore.Firestore;
  timestamp: () => FirebaseFirestore.Timestamp;
}

const defaultDeps: AggregateDeps = {
  firestore: () => admin.firestore(),
  timestamp: () => admin.firestore.Timestamp.now(),
};

const bucketBounds = [
  30_000,
  60_000,
  120_000,
  300_000,
  600_000,
  1_800_000,
  3_600_000,
  86_400_000,
  604_800_000,
];

/** Increments a public funnel counter without scanning response documents. */
export async function incrementOrganizerFormFunnel(params: {
  organizerId: string;
  formId: string;
  versionId: string;
  counter: "opens" | "starts";
  deps?: AggregateDeps;
}): Promise<void> {
  const deps = params.deps ?? defaultDeps;
  const db = deps.firestore();
  const ref = db.collection("organizerFormAggregates")
    .doc(versionAggregateId(params.formId, params.versionId));
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const aggregate = snap.exists ? requireDoc<OrganizerFormAggregateDocument>(
      snap,
      "OrganizerFormAggregateDocument"
    ) : emptyVersionAggregate(params, deps.timestamp());
    tx.set(ref, {
      ...aggregate,
      [params.counter]: aggregate[params.counter] + 1,
      updatedAt: deps.timestamp(),
    } satisfies OrganizerFormAggregateDocument);
  });
}

/**
 * Idempotently projects immutable answer aggregates on response transitions.
 */
export async function projectOrganizerFormResponseAggregate(
  responseId: string,
  before: OrganizerFormResponseDocument | undefined,
  after: OrganizerFormResponseDocument | undefined,
  deps: AggregateDeps = defaultDeps
): Promise<void> {
  const eventKind: AggregateEventKind | null = !before && after ?
    "submitted" : before?.status === "submitted" &&
      after?.status === "withdrawn" ? "withdrawn" : null;
  const response = after ?? before;
  if (!response || !eventKind) return;
  const db = deps.firestore();
  const versionRef = db.collection("organizerFormVersions")
    .doc(response.versionId);
  const versionSnap = await versionRef.get();
  const version = requireDoc<OrganizerFormVersionDocument>(
    versionSnap,
    "OrganizerFormVersionDocument"
  );
  if (version.organizerId !== response.organizerId ||
      version.formId !== response.formId) return;
  const questions = new Map(version.definition.sections.flatMap((section) =>
    section.questions).map((question) => [question.questionId, question]));
  const markerRef = db.collection("organizerFormAggregateEvents")
    .doc(aggregateEventId(responseId, eventKind));
  const versionAggregateRef = db.collection("organizerFormAggregates")
    .doc(versionAggregateId(response.formId, response.versionId));
  const answerEntries = eventKind === "submitted" ?
    response.answerSnapshots.flatMap((answer) => {
      const question = questions.get(answer.questionId);
      return question ? [{question, answer: answer.answer}] : [];
    }) : [];
  const questionRefs = answerEntries.map(({question}) =>
    db.collection("organizerFormAggregates")
      .doc(questionAggregateId(response.formId, response.versionId,
        question.questionId)));
  await db.runTransaction(async (tx) => {
    const [markerSnap, versionAggregateSnap, ...questionSnaps] =
      await Promise.all([
        tx.get(markerRef),
        tx.get(versionAggregateRef),
        ...questionRefs.map((ref) => tx.get(ref)),
      ]);
    if (markerSnap.exists) return;
    const now = deps.timestamp();
    const aggregate = versionAggregateSnap.exists ?
      requireDoc<OrganizerFormAggregateDocument>(
        versionAggregateSnap,
        "OrganizerFormAggregateDocument"
      ) : emptyVersionAggregate(response, now);
    const updatedVersion = eventKind === "submitted" ? {
      ...aggregate,
      submissions: aggregate.submissions + 1,
      completionMillisTotal:
        aggregate.completionMillisTotal + response.completionMillis,
      completionBuckets: incrementCompletionBucket(
        aggregate.completionBuckets,
        response.completionMillis
      ),
      updatedAt: now,
    } : {
      ...aggregate,
      withdrawals: aggregate.withdrawals + 1,
      updatedAt: now,
    };
    tx.set(versionAggregateRef, updatedVersion satisfies
      OrganizerFormAggregateDocument);
    if (eventKind === "submitted") {
      answerEntries.forEach(({question, answer}, index) => {
        const current = questionSnaps[index].exists ?
          requireDoc<OrganizerFormAggregateDocument>(
            questionSnaps[index],
            "OrganizerFormAggregateDocument"
          ) : emptyQuestionAggregate(response, question, now);
        tx.set(questionRefs[index], aggregateQuestionAnswer(
          current,
          question,
          answer,
          now
        ));
      });
    }
    const marker: OrganizerFormAggregateEventDocument = {
      organizerId: response.organizerId,
      formId: response.formId,
      versionId: response.versionId,
      responseId,
      eventKind,
      projectedAt: now,
      expiresAt: admin.firestore.Timestamp.fromMillis(
        now.toMillis() + 30 * 24 * 60 * 60 * 1000
      ),
    };
    tx.create(markerRef, marker);
  });
}

function aggregateQuestionAnswer(
  aggregate: OrganizerFormAggregateDocument,
  question: FormQuestion,
  answer: OrganizerFormResponseDocument["answers"][string],
  now: FirebaseFirestore.Timestamp
): OrganizerFormAggregateDocument {
  const choices = aggregate.choiceCounts.map((item) => ({...item}));
  const addChoice = (value: string | boolean, label: string) => {
    const existing = choices.find((item) => item.value === value);
    if (existing) existing.count += 1;
    else if (choices.length < 100) choices.push({value, label, count: 1});
  };
  if (question.kind === "singleChoice" && typeof answer === "string") {
    addChoice(answer, question.options.find((option) =>
      option.value === answer)?.label ?? answer);
  } else if (question.kind === "multiChoice" && Array.isArray(answer)) {
    for (const value of answer) {
      addChoice(value, question.options.find((option) =>
        option.value === value)?.label ?? value);
    }
  } else if ((question.kind === "boolean" ||
      question.kind === "acknowledgement") && typeof answer === "boolean") {
    addChoice(answer, answer ? "Yes" : "No");
  }
  const numeric = numericValue(question, answer);
  return {
    ...aggregate,
    submissions: aggregate.submissions + 1,
    choiceCounts: choices,
    numericCount: numeric === null ? aggregate.numericCount :
      aggregate.numericCount + 1,
    numericSum: numeric === null ? aggregate.numericSum :
      aggregate.numericSum + numeric,
    numericMin: numeric === null ? aggregate.numericMin :
      Math.min(aggregate.numericMin ?? numeric, numeric),
    numericMax: numeric === null ? aggregate.numericMax :
      Math.max(aggregate.numericMax ?? numeric, numeric),
    updatedAt: now,
  };
}

function numericValue(
  question: FormQuestion,
  answer: OrganizerFormResponseDocument["answers"][string]
): number | null {
  if (question.kind === "number" && typeof answer === "number") return answer;
  if (question.kind === "date" && typeof answer === "string") {
    const value = Date.parse(`${answer}T00:00:00.000Z`);
    return Number.isFinite(value) ? value : null;
  }
  return null;
}

function incrementCompletionBucket(
  existing: OrganizerFormAggregateDocument["completionBuckets"],
  completionMillis: number
): OrganizerFormAggregateDocument["completionBuckets"] {
  const counts = new Map(existing.map((item) =>
    [item.upperBoundMillis, item.count]));
  const upperBound = bucketBounds.find((bound) =>
    completionMillis <= bound) ?? bucketBounds.at(-1)!;
  counts.set(upperBound, (counts.get(upperBound) ?? 0) + 1);
  return bucketBounds.map((bound) => ({
    upperBoundMillis: bound,
    count: counts.get(bound) ?? 0,
  }));
}

function emptyVersionAggregate(
  source: {organizerId: string; formId: string; versionId: string},
  now: FirebaseFirestore.Timestamp
): OrganizerFormAggregateDocument {
  return {
    organizerId: source.organizerId,
    formId: source.formId,
    versionId: source.versionId,
    scope: "version",
    questionId: null,
    questionLabel: null,
    questionKind: null,
    privacyClass: null,
    opens: 0,
    starts: 0,
    submissions: 0,
    withdrawals: 0,
    completionMillisTotal: 0,
    completionBuckets: bucketBounds.map((upperBoundMillis) => ({
      upperBoundMillis,
      count: 0,
    })),
    choiceCounts: [],
    numericCount: 0,
    numericSum: 0,
    numericMin: null,
    numericMax: null,
    updatedAt: now,
  };
}

function emptyQuestionAggregate(
  response: OrganizerFormResponseDocument,
  question: FormQuestion,
  now: FirebaseFirestore.Timestamp
): OrganizerFormAggregateDocument {
  return {
    ...emptyVersionAggregate(response, now),
    scope: "question",
    questionId: question.questionId,
    questionLabel: question.label,
    questionKind: question.kind,
    privacyClass: question.privacyClass,
    completionBuckets: [],
  };
}

function versionAggregateId(formId: string, versionId: string): string {
  return digestId("formagg_version", formId, versionId);
}

function questionAggregateId(
  formId: string,
  versionId: string,
  questionId: string
): string {
  return digestId("formagg_question", formId, versionId, questionId);
}

function aggregateEventId(
  responseId: string,
  eventKind: AggregateEventKind
): string {
  return digestId("formagg_event", responseId, eventKind);
}

function digestId(prefix: string, ...parts: string[]): string {
  return `${prefix}_${createHash("sha256").update(parts.join("\u001f"))
    .digest("hex").slice(0, 32)}`;
}

export const onOrganizerFormResponseAggregated = onDocumentWritten(
  "organizerFormResponses/{responseId}",
  async (event) => {
    const before = event.data?.before.data() as
      OrganizerFormResponseDocument | undefined;
    const after = event.data?.after.data() as
      OrganizerFormResponseDocument | undefined;
    await projectOrganizerFormResponseAggregate(
      event.params.responseId,
      before,
      after
    );
  }
);
