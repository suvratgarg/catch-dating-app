import {strict as assert} from "node:assert";
import {describe, it} from "node:test";
import {OrganizerApplicationFormVersionDocument} from
  "../shared/generated/firestoreAdminTypes";
import {
  applicationOutreach,
  canonicalFieldForNormalizedHeader,
  normalizeHeader,
  normalizeTabularPayload,
  prepareApplicationRows,
} from "./organizerApplications";

const questions: OrganizerApplicationFormVersionDocument["questions"] = [
  {
    questionId: "name",
    key: "name",
    label: "Full name",
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
    questionId: "phone",
    key: "phone",
    label: "WhatsApp number",
    helpText: null,
    kind: "phone",
    required: true,
    options: [],
    canonicalFieldId: "phoneNumber",
    privacyClass: "contact",
    prefillPolicy: "participantReviewRequired",
    hostPresentation: "detailOnly",
  },
  {
    questionId: "cocktail",
    key: "favoriteCocktail",
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

const mappings: Parameters<typeof prepareApplicationRows>[0]["mappings"] = [
  {
    headerIndex: 0, question: questions[0], transform: "trim",
    confidence: "explicit",
  },
  {
    headerIndex: 1, question: questions[1], transform: "e164",
    confidence: "explicit",
  },
  {
    headerIndex: 2, question: questions[2], transform: "trim",
    confidence: "explicit",
  },
];

describe("organizer application tabular preparation", () => {
  it("keeps canonical data separate from organizer-only answers", () => {
    const [row] = prepareApplicationRows({
      headers: ["Name", "WhatsApp", "Favorite cocktail"],
      mappings,
      questions,
      rows: [{
        rowId: "2",
        values: ["  Ada Lovelace ", "+91 98765 43210", "Negroni"],
      }],
    });

    assert.equal(row.displayName, "Ada Lovelace");
    assert.deepEqual(row.errors, []);
    assert.equal(row.answers[1].canonicalFieldId, "phoneNumber");
    assert.equal(row.answers[1].value.textValue, "+919876543210");
    assert.equal(row.answers[2].canonicalFieldId, null);
    assert.equal(row.answers[2].value.textValue, "Negroni");
  });

  it("fails rows without a reviewable name or international phone", () => {
    const [row] = prepareApplicationRows({
      headers: ["Name", "WhatsApp", "Favorite cocktail"],
      mappings,
      questions,
      rows: [{rowId: "3", values: ["", "9876543210", ""]}],
    });

    assert.deepEqual(
      row.errors.map((error) => error.code),
      ["requiredValueMissing", "invalidPhone", "displayNameMissing"]
    );
  });
});

describe("organizer application safe outreach", () => {
  it("formats destinations and rejects lookalike social domains", () => {
    const answer = (
      field: "phoneNumber" | "email" | "instagramHandle" | "linkedinUrl",
      value: string
    ) => ({
      questionId: field,
      questionKey: field,
      questionLabel: field,
      questionKind: field === "phoneNumber" ? "phone" as const :
        field === "email" ? "email" as const : "url" as const,
      canonicalFieldId: field,
      privacyClass: "contact" as const,
      hostPresentation: "detailOnly" as const,
      value: {
        valueKind: "text" as const,
        textValue: value,
        numberValue: null,
        booleanValue: null,
        dateValue: null,
        optionValues: [],
        assetIds: [],
      },
    });
    const outreach = applicationOutreach([
      answer("phoneNumber", "+44 7700 900123"),
      answer("email", "Ada@Example.com"),
      answer("instagramHandle", "@ada.codes"),
      answer("linkedinUrl", "https://linkedin.com/in/ada"),
    ]);

    assert.deepEqual(outreach, {
      phoneE164: "+447700900123",
      email: "ada@example.com",
      instagramUrl: "https://www.instagram.com/ada.codes/",
      linkedinUrl: "https://linkedin.com/in/ada",
    });
    assert.equal(applicationOutreach([
      answer("linkedinUrl", "https://linkedin.com.evil.example/in/ada"),
    ]).linkedinUrl, null);
    assert.equal(applicationOutreach([
      answer("instagramHandle", "https://evilinstagram.com/ada"),
    ]).instagramUrl, null);
  });
});

it("normalizes common spreadsheet header punctuation", () => {
  assert.equal(normalizeHeader(" WhatsApp / Mobile # "), "whatsappmobile");
});

it("uses the shared person-field catalog for provider header aliases", () => {
  assert.equal(canonicalFieldForNormalizedHeader("birthdate"), "dateOfBirth");
  assert.equal(
    canonicalFieldForNormalizedHeader("whatsappnumber"),
    "phoneNumber"
  );
  assert.equal(canonicalFieldForNormalizedHeader("favoritecocktail"), null);
});

it("keeps preview normalization free of import-only properties", () => {
  assert.deepEqual(normalizeTabularPayload({
    organizerId: " club-1 ",
    formVersionId: " form-v1 ",
    headers: ["Name"],
    mappings: [],
    rows: [],
  }), {
    organizerId: "club-1",
    formVersionId: "form-v1",
    headers: ["Name"],
    mappings: [],
    rows: [],
  });
});
