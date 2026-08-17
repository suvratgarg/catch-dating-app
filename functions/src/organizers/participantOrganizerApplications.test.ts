import {strict as assert} from "node:assert";
import {describe, it} from "node:test";
import {HttpsError} from "firebase-functions/v2/https";
import {
  hostVisibleApplicationAnswers,
  participantOrganizerGrantId,
  prepareReviewedNativeAnswers,
} from "./participantOrganizerApplications";
import {
  OrganizerApplicationFormVersionDocument,
  OrganizerApplicationResponseDocument,
  ParticipantOrganizerDataGrantDocument,
} from "../shared/generated/firestoreAdminTypes";

const questions: OrganizerApplicationFormVersionDocument["questions"] = [
  {
    questionId: "name",
    key: "name",
    label: "Name",
    helpText: null,
    kind: "shortText",
    required: true,
    options: [],
    canonicalFieldId: "displayName",
    privacyClass: "contact",
    prefillPolicy: "participantReviewRequired",
    hostPresentation: "sortable",
  },
  {
    questionId: "cocktail",
    key: "cocktail",
    label: "Favorite cocktail",
    helpText: null,
    kind: "shortText",
    required: false,
    options: [],
    canonicalFieldId: null,
    privacyClass: "organizerCustom",
    prefillPolicy: "never",
    hostPresentation: "filterable",
  },
];

const value = (textValue: string | null) => ({
  valueKind: textValue === null ? "empty" as const : "text" as const,
  textValue,
  numberValue: null,
  booleanValue: null,
  dateValue: null,
  optionValues: [],
  assetIds: [],
});

describe("participant organizer application review boundary", () => {
  it("builds snapshots only after every current question was reviewed", () => {
    const answers = prepareReviewedNativeAnswers({
      questions,
      reviewedQuestionIds: ["cocktail", "name"],
      inputs: [
        {questionId: "name", value: value("Ada")},
        {questionId: "cocktail", value: value(null)},
      ],
    });
    assert.equal(answers[0].questionLabel, "Name");
    assert.equal(answers[1].value.valueKind, "empty");
  });

  it("rejects partial review even when required answers are present", () => {
    assert.throws(() => prepareReviewedNativeAnswers({
      questions,
      reviewedQuestionIds: ["name"],
      inputs: [
        {questionId: "name", value: value("Ada")},
        {questionId: "cocktail", value: value(null)},
      ],
    }), (error: unknown) => error instanceof HttpsError &&
      error.code === "invalid-argument");
  });
});

describe("Host application grant projection", () => {
  const applicationId = "application-1";
  const responseId = `${applicationId}_r1`;
  const response = {
    organizerId: "organizer-1",
    applicationId,
    formId: "form-1",
    formVersionId: "form-1_v1",
    linkedUid: "user-1",
    answers: prepareReviewedNativeAnswers({
      questions,
      reviewedQuestionIds: ["name", "cocktail"],
      inputs: [
        {questionId: "name", value: value("Ada")},
        {questionId: "cocktail", value: value("Negroni")},
      ],
    }),
    source: {
      kind: "native" as const,
      providerId: null,
      externalFormId: null,
      externalResponseId: null,
      importReceiptId: null,
    },
    consentVersion: "v1",
    grantId: participantOrganizerGrantId(applicationId),
    submittedAt: {} as FirebaseFirestore.Timestamp,
  } satisfies OrganizerApplicationResponseDocument;
  const grant = {
    participantUid: "user-1",
    organizerId: "organizer-1",
    applicationId,
    responseId,
    formVersionId: "form-1_v1",
    purpose: "organizerApplicationReview",
    grantedQuestionIds: ["name", "cocktail"],
    grantedCanonicalFieldIds: ["displayName"],
    consentVersion: "v1",
    consentCopyHash: "a".repeat(64),
    grantedAt: {} as FirebaseFirestore.Timestamp,
    revokedAt: null,
  } satisfies ParticipantOrganizerDataGrantDocument;

  it("returns exactly granted questions and canonical fields", () => {
    const visible = hostVisibleApplicationAnswers({
      response,
      responseId,
      grant: {...grant, grantedQuestionIds: ["cocktail"]},
    });
    assert.equal(visible.accessState, "activeParticipantGrant");
    assert.deepEqual(
      visible.answers.map((answer) => answer.questionId),
      ["cocktail"]
    );
  });

  it("returns no participant answers after revocation", () => {
    const visible = hostVisibleApplicationAnswers({
      response,
      responseId,
      grant: {
        ...grant,
        revokedAt: {toMillis: () => 1} as FirebaseFirestore.Timestamp,
      },
    });
    assert.equal(visible.accessState, "revokedParticipantGrant");
    assert.deepEqual(visible.answers, []);
  });
});
