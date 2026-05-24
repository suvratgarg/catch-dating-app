#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {createRequire} from "node:module";
import {fileURLToPath} from "node:url";

const requireFromFunctions = createRequire(
  new URL("../../functions/package.json", import.meta.url)
);
const {compile} = requireFromFunctions("json-schema-to-typescript");

const toolDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(toolDir, "../..");
const contractRoot = path.join(repoRoot, "contracts");
const checkOnly = process.argv.includes("--check");

const schemaSpecs = [
  {
    name: "ProfilePromptAnswer",
    source: "embedded/profile_prompt_answer.schema.json",
    typeOutput: "functions/src/shared/generated/profilePromptAnswer.ts",
  },
  {
    name: "PhotoPromptAnswer",
    source: "embedded/photo_prompt_answer.schema.json",
    typeOutput: "functions/src/shared/generated/photoPromptAnswer.ts",
  },
  {
    name: "ProfilePhoto",
    source: "embedded/profile_photo.schema.json",
    typeOutput: "functions/src/shared/generated/profilePhoto.ts",
  },
  {
    name: "ConfigCitiesDocument",
    source: "firestore/config_cities.schema.json",
    typeOutput: "functions/src/shared/generated/configCitiesDocument.ts",
  },
  {
    name: "OnboardingDraftDocument",
    source: "firestore/onboarding_drafts.schema.json",
    typeOutput: "functions/src/shared/generated/onboardingDraftDocument.ts",
  },
  {
    name: "UserProfileDocument",
    source: "firestore/users.schema.json",
    typeOutput: "functions/src/shared/generated/userProfileDocument.ts",
  },
  {
    name: "PublicProfileDocument",
    source: "firestore/public_profiles.schema.json",
    typeOutput: "functions/src/shared/generated/publicProfileDocument.ts",
  },
  {
    name: "ClubDocument",
    source: "firestore/clubs.schema.json",
    typeOutput: "functions/src/shared/generated/clubDocument.ts",
  },
  {
    name: "ClubMembershipDocument",
    source: "firestore/club_memberships.schema.json",
    typeOutput: "functions/src/shared/generated/clubMembershipDocument.ts",
  },
  {
    name: "ClubHostClaimDocument",
    source: "firestore/club_host_claims.schema.json",
    typeOutput: "functions/src/shared/generated/clubHostClaimDocument.ts",
  },
  {
    name: "EventDocument",
    source: "firestore/events.schema.json",
    typeOutput: "functions/src/shared/generated/eventDocument.ts",
  },
  {
    name: "EventPrivateAccessDocument",
    source: "firestore/event_private_access.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventPrivateAccessDocument.ts",
  },
  {
    name: "EventParticipationDocument",
    source: "firestore/event_participations.schema.json",
    typeOutput: "functions/src/shared/generated/eventParticipationDocument.ts",
  },
  {
    name: "EventSuccessPlanDocument",
    source: "firestore/event_success_plans.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventSuccessPlanDocument.ts",
  },
  {
    name: "EventSuccessFeedbackDocument",
    source: "firestore/event_success_feedback.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventSuccessFeedbackDocument.ts",
  },
  {
    name: "EventSuccessPreferenceDocument",
    source: "firestore/event_success_preferences.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventSuccessPreferenceDocument.ts",
  },
  {
    name: "EventSuccessCompatibilityResponseDocument",
    source: "firestore/event_success_compatibility_responses.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventSuccessCompatibilityResponseDocument.ts",
  },
  {
    name: "EventSuccessWingmanRequestDocument",
    source: "firestore/event_success_wingman_requests.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventSuccessWingmanRequestDocument.ts",
  },
  {
    name: "EventSuccessArrivalMissionDocument",
    source: "firestore/event_success_arrival_missions.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventSuccessArrivalMissionDocument.ts",
  },
  {
    name: "EventSuccessAssignmentDocument",
    source: "firestore/event_success_assignments.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventSuccessAssignmentDocument.ts",
  },
  {
    name: "EventSuccessScorecardDocument",
    source: "firestore/event_success_scorecards.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventSuccessScorecardDocument.ts",
  },
  {
    name: "EventSafetyReportDocument",
    source: "firestore/event_safety_reports.schema.json",
    typeOutput:
      "functions/src/shared/generated/eventSafetyReportDocument.ts",
  },
  {
    name: "ClubScheduleLockDocument",
    source: "firestore/club_schedule_locks.schema.json",
    typeOutput:
      "functions/src/shared/generated/clubScheduleLockDocument.ts",
  },
  {
    name: "UserEventScheduleLockDocument",
    source: "firestore/user_event_schedule_locks.schema.json",
    typeOutput:
      "functions/src/shared/generated/userEventScheduleLockDocument.ts",
  },
  {
    name: "SavedEventDocument",
    source: "firestore/saved_events.schema.json",
    typeOutput: "functions/src/shared/generated/savedEventDocument.ts",
  },
  {
    name: "PaymentDocument",
    source: "firestore/payments.schema.json",
    typeOutput: "functions/src/shared/generated/paymentDocument.ts",
  },
  {
    name: "SwipeDocument",
    source: "firestore/swipes.schema.json",
    typeOutput: "functions/src/shared/generated/swipeDocument.ts",
  },
  {
    name: "MatchDocument",
    source: "firestore/matches.schema.json",
    typeOutput: "functions/src/shared/generated/matchDocument.ts",
  },
  {
    name: "ChatMessageDocument",
    source: "firestore/chat_messages.schema.json",
    typeOutput: "functions/src/shared/generated/chatMessageDocument.ts",
  },
  {
    name: "ActivityNotificationDocument",
    source: "firestore/activity_notifications.schema.json",
    typeOutput:
      "functions/src/shared/generated/activityNotificationDocument.ts",
  },
  {
    name: "ReviewDocument",
    source: "firestore/reviews.schema.json",
    typeOutput: "functions/src/shared/generated/reviewDocument.ts",
  },
  {
    name: "BlockDocument",
    source: "firestore/blocks.schema.json",
    typeOutput: "functions/src/shared/generated/blockDocument.ts",
  },
  {
    name: "ReportDocument",
    source: "firestore/reports.schema.json",
    typeOutput: "functions/src/shared/generated/reportDocument.ts",
  },
  {
    name: "ModerationFlagDocument",
    source: "firestore/moderation_flags.schema.json",
    typeOutput: "functions/src/shared/generated/moderationFlagDocument.ts",
  },
  {
    name: "DeletedUserTombstoneDocument",
    source: "firestore/deleted_users.schema.json",
    typeOutput:
      "functions/src/shared/generated/deletedUserTombstoneDocument.ts",
  },
  {
    name: "RateLimitDocument",
    source: "firestore/rate_limits.schema.json",
    typeOutput: "functions/src/shared/generated/rateLimitDocument.ts",
  },
  {
    name: "FunctionEventReceiptDocument",
    source: "firestore/function_event_receipts.schema.json",
    typeOutput:
      "functions/src/shared/generated/functionEventReceiptDocument.ts",
  },
  {
    name: "SeedEventManifestDocument",
    source: "firestore/seed_events.schema.json",
    typeOutput: "functions/src/shared/generated/seedEventManifestDocument.ts",
  },
  {
    name: "UpdateUserProfileCallablePayload",
    source: "patches/update_user_profile.schema.json",
    typeOutput:
      "functions/src/shared/generated/updateUserProfileCallablePayload.ts",
  },
  {
    name: "CreateClubCallablePayload",
    source: "callables/create_club_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/createClubCallablePayload.ts",
  },
  {
    name: "CreateClubCallableResponse",
    source: "callable_responses/create_club_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/createClubCallableResponse.ts",
  },
  {
    name: "UpdateClubCallablePayload",
    source: "callables/update_club_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/updateClubCallablePayload.ts",
  },
  {
    name: "AddClubHostCallablePayload",
    source: "callables/add_club_host_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/addClubHostCallablePayload.ts",
  },
  {
    name: "RemoveClubHostCallablePayload",
    source: "callables/remove_club_host_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/removeClubHostCallablePayload.ts",
  },
  {
    name: "ArchiveClubCallablePayload",
    source: "callables/archive_club_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/archiveClubCallablePayload.ts",
  },
  {
    name: "DeleteClubCallablePayload",
    source: "callables/delete_club_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/deleteClubCallablePayload.ts",
  },
  {
    name: "ClubMembershipCallablePayload",
    source: "callables/club_membership_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/clubMembershipCallablePayload.ts",
  },
  {
    name: "SetClubNotificationPreferenceCallablePayload",
    source: "callables/set_club_notification_preference_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/setClubNotificationPreferenceCallablePayload.ts",
  },
  {
    name: "CreateEventCallablePayload",
    source: "callables/create_event_payload.schema.json",
    typeOutput: "functions/src/shared/generated/createEventCallablePayload.ts",
  },
  {
    name: "UpdateEventCallablePayload",
    source: "callables/update_event_payload.schema.json",
    typeOutput: "functions/src/shared/generated/updateEventCallablePayload.ts",
  },
  {
    name: "CancelEventCallablePayload",
    source: "callables/cancel_event_payload.schema.json",
    typeOutput: "functions/src/shared/generated/cancelEventCallablePayload.ts",
  },
  {
    name: "DeleteEventCallablePayload",
    source: "callables/delete_event_payload.schema.json",
    typeOutput: "functions/src/shared/generated/deleteEventCallablePayload.ts",
  },
  {
    name: "EventIdCallablePayload",
    source: "callables/event_id_payload.schema.json",
    typeOutput: "functions/src/shared/generated/eventIdCallablePayload.ts",
  },
  {
    name: "MarkEventAttendanceCallablePayload",
    source: "callables/mark_event_attendance_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/markEventAttendanceCallablePayload.ts",
  },
  {
    name: "OverrideEventSuccessRotationsCallablePayload",
    source: "callables/override_event_success_rotations_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "overrideEventSuccessRotationsCallablePayload.ts",
  },
  {
    name: "SubmitEventSuccessWingmanRequestCallablePayload",
    source:
      "callables/submit_event_success_wingman_request_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "submitEventSuccessWingmanRequestCallablePayload.ts",
  },
  {
    name: "StartEventSuccessFirstHelloMissionCallablePayload",
    source:
      "callables/start_event_success_first_hello_mission_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "startEventSuccessFirstHelloMissionCallablePayload.ts",
  },
  {
    name: "CompleteEventSuccessFirstHelloMissionCallablePayload",
    source:
      "callables/complete_event_success_first_hello_mission_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/" +
      "completeEventSuccessFirstHelloMissionCallablePayload.ts",
  },
  {
    name: "MarkEventAttendanceCallableResponse",
    source: "callable_responses/mark_event_attendance_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/markEventAttendanceCallableResponse.ts",
  },
  {
    name: "SelfCheckInAttendanceCallablePayload",
    source: "callables/self_check_in_attendance_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/selfCheckInAttendanceCallablePayload.ts",
  },
  {
    name: "CreateEventReviewCallablePayload",
    source: "callables/create_event_review_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/createEventReviewCallablePayload.ts",
  },
  {
    name: "UpdateEventReviewCallablePayload",
    source: "callables/update_event_review_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/updateEventReviewCallablePayload.ts",
  },
  {
    name: "DeleteEventReviewCallablePayload",
    source: "callables/delete_event_review_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/deleteEventReviewCallablePayload.ts",
  },
  {
    name: "BlockUserCallablePayload",
    source: "callables/block_user_payload.schema.json",
    typeOutput: "functions/src/shared/generated/blockUserCallablePayload.ts",
  },
  {
    name: "UnblockUserCallablePayload",
    source: "callables/unblock_user_payload.schema.json",
    typeOutput: "functions/src/shared/generated/unblockUserCallablePayload.ts",
  },
  {
    name: "ReportUserCallablePayload",
    source: "callables/report_user_payload.schema.json",
    typeOutput: "functions/src/shared/generated/reportUserCallablePayload.ts",
  },
  {
    name: "VerifyRazorpayPaymentCallablePayload",
    source: "callables/verify_razorpay_payment_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/verifyRazorpayPaymentCallablePayload.ts",
  },
  {
    name: "RazorpayOrderCallableResponse",
    source: "callable_responses/razorpay_order_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/razorpayOrderCallableResponse.ts",
  },
  {
    name: "PlacesAutocompleteCallablePayload",
    source: "callables/places_autocomplete_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/placesAutocompleteCallablePayload.ts",
  },
  {
    name: "PlacesAutocompleteCallableResponse",
    source: "callable_responses/places_autocomplete_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/placesAutocompleteCallableResponse.ts",
  },
  {
    name: "PlaceDetailsCallablePayload",
    source: "callables/place_details_payload.schema.json",
    typeOutput:
      "functions/src/shared/generated/placeDetailsCallablePayload.ts",
  },
  {
    name: "PlaceDetailsCallableResponse",
    source: "callable_responses/place_details_response.schema.json",
    typeOutput:
      "functions/src/shared/generated/placeDetailsCallableResponse.ts",
  },
  {
    name: "CreateProfileDecisionClientWrite",
    source: "client_writes/create_profile_decision.schema.json",
    typeOutput:
      "functions/src/shared/generated/createProfileDecisionClientWrite.ts",
  },
  {
    name: "CreateChatMessageClientWrite",
    source: "client_writes/create_chat_message.schema.json",
    typeOutput:
      "functions/src/shared/generated/createChatMessageClientWrite.ts",
  },
  {
    name: "CreateSavedEventClientWrite",
    source: "client_writes/create_saved_event.schema.json",
    typeOutput:
      "functions/src/shared/generated/createSavedEventClientWrite.ts",
  },
  {
    name: "DeleteSavedEventClientWrite",
    source: "client_writes/delete_saved_event.schema.json",
    typeOutput:
      "functions/src/shared/generated/deleteSavedEventClientWrite.ts",
  },
  {
    name: "MarkNotificationReadClientWrite",
    source: "client_writes/mark_notification_read.schema.json",
    typeOutput:
      "functions/src/shared/generated/markNotificationReadClientWrite.ts",
  },
  {
    name: "ResetMatchUnreadCountClientWrite",
    source: "client_writes/reset_match_unread_count.schema.json",
    typeOutput:
      "functions/src/shared/generated/resetMatchUnreadCountClientWrite.ts",
  },
];

const generatedFiles = [];

async function main() {
  const profileCatalog = readContractJson("catalogs/profile_prompts.json");
  const profilePhotoPolicy = readContractJson(
    "catalogs/profile_photo_policy.json"
  );
  const photoCatalog = withProfilePhotoPolicy(
    readContractJson("catalogs/photo_prompts.json"),
    profilePhotoPolicy
  );
  const profileDecisionMigration = readContractJson(
    "migrations/swipes_to_profile_decisions.json"
  );
  const bundledSchemas = new Map();

  for (const spec of schemaSpecs) {
    const file = path.join(contractRoot, spec.source);
    const schema = applyProfilePhotoPolicy(
      bundleSchema(file),
      profilePhotoPolicy
    );
    bundledSchemas.set(spec.name, schema);
    await addTypeOutput(spec, schema);
  }

  addTextOutput(
    "functions/src/shared/generated/schemaRegistry.ts",
    renderTsSchemaRegistry({
      schemaMap: bundledSchemas,
      profileCatalog,
      photoCatalog,
      profilePhotoPolicy,
    })
  );
  addTextOutput(
    "functions/src/shared/generated/schemaValidators.ts",
    renderTsValidators()
  );
  addTextOutput(
    "functions/src/shared/generated/schemaPaths.ts",
    renderTsPathConstants({
      profileDecisionSchema: bundledSchemas.get("SwipeDocument"),
      profileDecisionMigration,
    })
  );
  addTextOutput(
    "tool/contracts/generated/schema_contract_registry.mjs",
    renderToolSchemaRegistry({
      schemaMap: bundledSchemas,
      profileCatalog,
      photoCatalog,
      profilePhotoPolicy,
    })
  );
  addTextOutput(
    "tool/contracts/generated/schema_contract_validators.mjs",
    renderToolValidators()
  );
  addTextOutput(
    "lib/core/schema_contracts/generated/profile_schema_contracts.g.dart",
    renderDartContracts({
      profileCatalog,
      photoCatalog,
      profilePhotoPolicy,
      profilePromptSchema: bundledSchemas.get("ProfilePromptAnswer"),
      photoPromptSchema: bundledSchemas.get("PhotoPromptAnswer"),
      profilePhotoSchema: bundledSchemas.get("ProfilePhoto"),
      updateUserProfileSchema: bundledSchemas.get(
        "UpdateUserProfileCallablePayload"
      ),
      profileDecisionSchema: bundledSchemas.get("SwipeDocument"),
      profileDecisionMigration,
      commonSchema: readContractJson("shared/profile_common.schema.json"),
    })
  );
  addTextOutput(
    "lib/core/schema_contracts/generated/schema_contracts.g.dart",
    renderDartSchemaContracts({schemaMap: bundledSchemas})
  );

  const staleFiles = [];
  for (const file of generatedFiles) {
    const absolutePath = path.join(repoRoot, file.path);
    if (checkOnly) {
      const current = fs.existsSync(absolutePath) ?
        fs.readFileSync(absolutePath, "utf8") :
        null;
      if (current !== file.content) staleFiles.push(file.path);
    } else {
      fs.mkdirSync(path.dirname(absolutePath), {recursive: true});
      fs.writeFileSync(absolutePath, file.content);
    }
  }

  if (staleFiles.length > 0) {
    console.error("Generated schema contract outputs are stale:");
    for (const file of staleFiles) console.error(`- ${file}`);
    console.error("Run: node tool/contracts/generate_schema_contracts.mjs");
    process.exitCode = 1;
    return;
  }

  console.log(
    checkOnly ?
      "Generated schema contract outputs are current." :
      `Generated ${generatedFiles.length} schema contract files.`
  );
}

function withProfilePhotoPolicy(photoCatalog, profilePhotoPolicy) {
  return {
    ...photoCatalog,
    limits: {
      ...photoCatalog.limits,
      maxCaptions: profilePhotoPolicy.maxPhotos,
    },
  };
}

function applyProfilePhotoPolicy(schema, profilePhotoPolicy) {
  const cloned = structuredClone(schema);
  applyDerivedProfilePhotoPolicyValues(cloned, profilePhotoPolicy);
  return cloned;
}

function applyDerivedProfilePhotoPolicyValues(value, profilePhotoPolicy) {
  if (Array.isArray(value)) {
    for (const item of value) {
      applyDerivedProfilePhotoPolicyValues(item, profilePhotoPolicy);
    }
    return;
  }
  if (!value || typeof value !== "object") return;
  if (
    value["x-catch-maximumFrom"] ===
    "profilePhotoPolicy.maxPhotosMinusOne"
  ) {
    value.maximum = profilePhotoPolicy.maxPhotos - 1;
    delete value["x-catch-maximumFrom"];
  }
  for (const child of Object.values(value)) {
    applyDerivedProfilePhotoPolicyValues(child, profilePhotoPolicy);
  }
}

async function addTypeOutput(spec, schema) {
  let types = await compile(schema, spec.name, {
    bannerComment: "",
    cwd: repoRoot,
    declareExternallyReferenced: false,
    enableConstEnums: false,
    format: true,
    ignoreMinAndMaxItems: true,
    style: {
      bracketSpacing: false,
      printWidth: 80,
      semi: true,
      singleQuote: false,
      tabWidth: 2,
      trailingComma: "es5",
      useTabs: false,
    },
  });
  types = normalizeExternalTypeReferences(spec.name, types);
  const imports = tsTypeImports(spec.name, types);
  addTextOutput(
    spec.typeOutput,
    `${tsGeneratedHeader()}${imports}${types.trim()}\n`
  );
}

function normalizeExternalTypeReferences(currentTypeName, source) {
  let normalized = source;
  for (const spec of schemaSpecs) {
    if (currentTypeName === spec.name) continue;
    normalized = normalized.replace(
      new RegExp(`\\b${spec.name}\\d+\\b`, "g"),
      spec.name
    );
  }
  return normalized;
}

function tsTypeImports(currentTypeName, source) {
  const imports = [];
  for (const spec of schemaSpecs) {
    if (currentTypeName === spec.name) continue;
    const pattern = new RegExp(`\\b${spec.name}\\b`);
    if (!pattern.test(source)) continue;
    imports.push(`import {${spec.name}} from "${typeImportPath(spec)}";`);
  }
  return imports.length === 0 ? "" : `${imports.join("\n")}\n\n`;
}

function addTextOutput(relativePath, content) {
  generatedFiles.push({path: relativePath, content});
}

function schemaRegistryEntries(schemaMap) {
  return schemaSpecs.map((spec) => [
    schemaConstName(spec),
    schemaMap.get(spec.name),
  ]);
}

function schemaConstName(spec) {
  return `${spec.name.charAt(0).toLowerCase()}${spec.name.slice(1)}Schema`;
}

function validatorName(spec) {
  return `validate${spec.name}`;
}

function typeImportPath(spec) {
  return `./${path.basename(spec.typeOutput, ".ts")}`;
}

function renderTsSchemaRegistry({
  schemaMap,
  profileCatalog,
  photoCatalog,
  profilePhotoPolicy,
}) {
  const entries = schemaRegistryEntries(schemaMap);
  const catalogEntries = [
    ["profilePromptCatalog", profileCatalog],
    ["photoPromptCatalog", photoCatalog],
    ["profilePromptLimits", profileCatalog.limits],
    ["photoPromptLimits", photoCatalog.limits],
    ["profilePhotoPolicy", profilePhotoPolicy],
    ["defaultProfilePromptIds", profileCatalog.defaultPromptIds],
  ];
  return `${tsGeneratedHeader()}${entries.map(([name, schema]) =>
    `export const ${name}: Record<string, unknown> = ${jsonForTs(schema)};\n`
  ).join("\n")}\n${catalogEntries.map(([name, value]) =>
    `export const ${name} = ${jsonForTs(value)};\n`
  ).join("\n")}`;
}

function renderTsValidators() {
  const typeImports = schemaSpecs.map((spec) =>
    `import {${spec.name}} from "${typeImportPath(spec)}";`
  ).join("\n");
  const schemaImports = schemaSpecs.map((spec) =>
    `  ${schemaConstName(spec)},`
  ).join("\n");
  const validators = schemaSpecs.map((spec) => `export const ${validatorName(spec)}:
  ValidateFunction<${spec.name}> =
    ajv.compile(${schemaConstName(spec)}) as
      ValidateFunction<${spec.name}>;`).join("\n");

  return `${tsGeneratedHeader()}import Ajv, {ValidateFunction} from "ajv";
import addFormats from "ajv-formats";
${typeImports}
import {
${schemaImports}
} from "./schemaRegistry";

const ajv = new Ajv({allErrors: true, strict: false});
addFormats(ajv);

${validators}

export function schemaErrorMessages(
  validator: ValidateFunction<unknown>
): string[] {
  return (validator.errors ?? []).map((error) => {
    const location = error.instancePath || "/";
    return \`\${location} \${error.message ?? "failed validation"}\`;
  });
}
`;
}

function renderTsPathConstants({
  profileDecisionSchema,
  profileDecisionMigration,
}) {
  const pathParts = profileDecisionPathParts(profileDecisionSchema);
  const futurePathParts = profileDecisionPathParts(
    profileDecisionMigration?.candidatePrimaryStoragePath
  );
  return `${tsGeneratedHeader()}export const schemaProfileDecisionLogicalName =
  ${JSON.stringify(profileDecisionSchema["x-logical-name"] ?? "profileDecision")};
export const schemaProfileDecisionPathTemplate =
  ${JSON.stringify(pathParts.pathTemplate)};
export const schemaProfileDecisionTriggerPath =
  ${JSON.stringify(pathParts.triggerPath)};
export const schemaProfileDecisionCollectionPath =
  ${JSON.stringify(pathParts.collectionPath)};
export const schemaProfileDecisionOutgoingSubcollectionPath =
  ${JSON.stringify(pathParts.outgoingSubcollectionPath)};
export const schemaProfileDecisionFuturePathTemplate =
  ${JSON.stringify(futurePathParts.pathTemplate)};
export const schemaProfileDecisionFutureCollectionPath =
  ${JSON.stringify(futurePathParts.collectionPath)};
export const schemaProfileDecisionFutureOutgoingSubcollectionPath =
  ${JSON.stringify(futurePathParts.outgoingSubcollectionPath)};
`;
}

function renderToolSchemaRegistry({
  schemaMap,
  profileCatalog,
  photoCatalog,
  profilePhotoPolicy,
}) {
  const entries = schemaRegistryEntries(schemaMap);
  const catalogEntries = [
    ["profilePromptCatalog", profileCatalog],
    ["photoPromptCatalog", photoCatalog],
    ["profilePromptLimits", profileCatalog.limits],
    ["photoPromptLimits", photoCatalog.limits],
    ["profilePhotoPolicy", profilePhotoPolicy],
    ["defaultProfilePromptIds", profileCatalog.defaultPromptIds],
  ];
  return `${mjsGeneratedHeader()}${entries.map(([name, schema]) =>
    `export const ${name} = ${jsonForJs(schema)};\n`
  ).join("\n")}\n${catalogEntries.map(([name, value]) =>
    `export const ${name} = ${jsonForJs(value)};\n`
  ).join("\n")}`;
}

function renderToolValidators() {
  const schemaImports = schemaSpecs.map((spec) =>
    `  ${schemaConstName(spec)},`
  ).join("\n");
  const validators = schemaSpecs.map((spec) =>
    `export const ${validatorName(spec)} = ajv.compile(${schemaConstName(spec)});`
  ).join("\n");

  return `${mjsGeneratedHeader()}import {createRequire} from "node:module";
import {
${schemaImports}
} from "./schema_contract_registry.mjs";

const requireFromFunctions = createRequire(
  new URL("../../../functions/package.json", import.meta.url)
);
const Ajv = requireFromFunctions("ajv");
const addFormats = requireFromFunctions("ajv-formats");

const ajv = new Ajv({allErrors: true, strict: false});
addFormats(ajv);

${validators}

export function schemaErrorMessages(validator) {
  return (validator.errors ?? []).map((error) => {
    const location = error.instancePath || "/";
    return \`\${location} \${error.message ?? "failed validation"}\`;
  });
}

export function assertValidSchemaPayload(validator, payload, label) {
  if (validator(payload)) return;
  const details = schemaErrorMessages(validator).join("; ");
  throw new Error(\`\${label} failed schema validation: \${details}\`);
}
`;
}

function renderDartContracts({
  profileCatalog,
  photoCatalog,
  profilePhotoPolicy,
  profilePromptSchema,
  photoPromptSchema,
  profilePhotoSchema,
  updateUserProfileSchema,
  profileDecisionSchema,
  profileDecisionMigration,
  commonSchema,
}) {
  const profileLimits = profileCatalog.limits;
  const photoLimits = photoCatalog.limits;
  const height = commonSchema.definitions.heightCm;
  const profileDecisionPath = profileDecisionPathParts(profileDecisionSchema);
  const profileDecisionFuturePath = profileDecisionPathParts(
    profileDecisionMigration?.candidatePrimaryStoragePath
  );
  const preferredAge = updateUserProfileSchema.properties.fields.properties
    .minAgePreference;
  const profilePrompts = profileCatalog.prompts.map((prompt) =>
    `  SchemaProfilePromptDefinition(` +
    `id: ${dartString(prompt.id)}, ` +
    `title: ${dartString(prompt.title)}, ` +
    `placeholder: ${dartString(prompt.placeholder)},` +
    `),`
  ).join("\n");
  const photoPrompts = photoCatalog.prompts.map((prompt) =>
    `  SchemaPhotoPromptDefinition(` +
    `id: ${dartString(prompt.id)}, ` +
    `title: ${dartString(prompt.title)}, ` +
    `placeholder: ${dartString(prompt.placeholder)},` +
    `),`
  ).join("\n");
  const defaultPromptIds = profileCatalog.defaultPromptIds
    .map((id) => `  ${dartString(id)},`)
    .join("\n");

  return `${dartGeneratedHeader()}
class SchemaProfilePromptDefinition {
  const SchemaProfilePromptDefinition({
    required this.id,
    required this.title,
    required this.placeholder,
  });

  final String id;
  final String title;
  final String placeholder;
}

class SchemaPhotoPromptDefinition {
  const SchemaPhotoPromptDefinition({
    required this.id,
    required this.title,
    required this.placeholder,
  });

  final String id;
  final String title;
  final String placeholder;
}

const schemaProfilePromptPerfectEventId = ${dartString(
  profileCatalog.defaultPromptIds[0]
)};
const schemaMaxProfilePromptAnswers = ${profileLimits.maxAnswers};
const schemaMaxPhotoPromptCaptions = ${photoLimits.maxCaptions};
const schemaMinimumProfilePhotos = ${profilePhotoPolicy.minPhotos};
const schemaMaximumProfilePhotos = ${profilePhotoPolicy.maxPhotos};
const schemaProfilePhotoAspectRatioWidth =
    ${profilePhotoPolicy.displayAspectRatio.width};
const schemaProfilePhotoAspectRatioHeight =
    ${profilePhotoPolicy.displayAspectRatio.height};
const schemaProfilePhotoThumbnailSize = ${profilePhotoPolicy.thumbnailSize};
const schemaProfilePhotoMaxUploadBytes = ${profilePhotoPolicy.maxUploadBytes};
const schemaMaximumProfilePromptAnswerLength =
    ${profileLimits.maxAnswerLength};
const schemaMaximumPhotoPromptCaptionLength = ${photoLimits.maxCaptionLength};
const schemaMinimumProfileAge = ${preferredAge.minimum};
const schemaMaximumPreferredMatchAge = ${preferredAge.maximum};
const schemaMinimumHeightCm = ${height.minimum};
const schemaMaximumHeightCm = ${height.maximum};
const schemaProfileDecisionLogicalName =
    ${dartString(profileDecisionSchema["x-logical-name"] ?? "profileDecision")};
const schemaProfileDecisionPathTemplate =
    ${dartString(profileDecisionPath.pathTemplate)};
const schemaProfileDecisionCollectionPath =
    ${dartString(profileDecisionPath.collectionPath)};
const schemaProfileDecisionOutgoingSubcollectionPath =
    ${dartString(profileDecisionPath.outgoingSubcollectionPath)};
const schemaProfileDecisionFuturePathTemplate =
    ${dartString(profileDecisionFuturePath.pathTemplate)};
const schemaProfileDecisionFutureCollectionPath =
    ${dartString(profileDecisionFuturePath.collectionPath)};
const schemaProfileDecisionFutureOutgoingSubcollectionPath =
    ${dartString(profileDecisionFuturePath.outgoingSubcollectionPath)};

const schemaDefaultProfilePromptIds = <String>[
${defaultPromptIds}
];

const schemaProfilePromptCatalog = <SchemaProfilePromptDefinition>[
${profilePrompts}
];

const schemaPhotoPromptCatalog = <SchemaPhotoPromptDefinition>[
${photoPrompts}
];

const schemaProfilePromptAnswerSchema = ${dartLiteral(profilePromptSchema)};

const schemaPhotoPromptAnswerSchema = ${dartLiteral(photoPromptSchema)};

const schemaProfilePhotoSchema = ${dartLiteral(profilePhotoSchema)};

const schemaUpdateUserProfileCallablePayloadSchema =
    ${dartLiteral(updateUserProfileSchema)};
`;
}

function renderDartSchemaContracts({schemaMap}) {
  const schemaConstants = schemaSpecs.map((spec) => {
    const name = dartSchemaConstName(spec.name);
    return `const ${name} = ${dartLiteral(schemaMap.get(spec.name))};`;
  }).join("\n\n");
  const definitions = schemaSpecs.map((spec) => {
    const schemaName = dartSchemaConstName(spec.name);
    return `  SchemaContractDefinition(
    name: ${dartString(spec.name)},
    source: ${dartString(spec.source)},
    schema: ${schemaName},
  ),`;
  }).join("\n");
  const byName = schemaSpecs.map((spec) =>
    `  ${dartString(spec.name)}: ${dartSchemaConstName(spec.name)},`
  ).join("\n");
  const bySource = schemaSpecs.map((spec) =>
    `  ${dartString(spec.source)}: ${dartSchemaConstName(spec.name)},`
  ).join("\n");

  return `${dartGeneratedHeader()}
class SchemaContractDefinition {
  const SchemaContractDefinition({
    required this.name,
    required this.source,
    required this.schema,
  });

  final String name;
  final String source;
  final Map<String, Object?> schema;
}

${schemaConstants}

const schemaContractDefinitions = <SchemaContractDefinition>[
${definitions}
];

const schemaContractsByName = <String, Map<String, Object?>>{
${byName}
};

const schemaContractsBySource = <String, Map<String, Object?>>{
${bySource}
};
`;
}

function dartSchemaConstName(name) {
  return `schema${name}Schema`;
}

function profileDecisionPathParts(schemaOrPath) {
  const pathTemplate = typeof schemaOrPath === "string" ?
    schemaOrPath :
    schemaOrPath?.["x-firestore-path"];
  if (typeof pathTemplate !== "string") {
    throw new Error("Profile decision path template is missing.");
  }
  const parts = pathTemplate.split("/");
  if (parts.length !== 4 || parts[2] !== "outgoing") {
    throw new Error(
      `Unexpected profile decision path template: ${pathTemplate}`
    );
  }
  return {
    pathTemplate,
    triggerPath: pathTemplate
      .replace("{userId}", "{swiperId}")
      .replace("{targetId}", "{targetId}"),
    collectionPath: parts[0],
    outgoingSubcollectionPath: parts[2],
  };
}

function bundleSchema(file) {
  const absoluteFile = path.resolve(file);
  const schema = readJsonFile(absoluteFile);
  return resolveRefs(schema, absoluteFile, true);
}

function resolveRefs(node, currentFile, keepSchemaMeta) {
  if (Array.isArray(node)) {
    return node.map((item) => resolveRefs(item, currentFile, false));
  }
  if (!node || typeof node !== "object") return node;

  if (typeof node.$ref === "string") {
    const {$ref, ...siblings} = node;
    const resolved = resolveReference($ref, currentFile);
    const merged = {
      ...stripSchemaMeta(resolveRefs(resolved.value, resolved.file, false)),
      ...resolveRefs(siblings, currentFile, false),
    };
    return Object.keys(merged).length === 0 ? true : merged;
  }

  const result = {};
  for (const [key, value] of Object.entries(node)) {
    if (!keepSchemaMeta && (key === "$schema" || key === "$id")) continue;
    result[key] = resolveRefs(value, currentFile, false);
  }
  return result;
}

function resolveReference(ref, currentFile) {
  if (/^[a-z]+:\/\//i.test(ref)) {
    throw new Error(`Remote schema refs are not supported by this generator: ${
      ref
    }`);
  }
  const [target, pointer = ""] = ref.split("#");
  const file = target ?
    path.resolve(path.dirname(currentFile), target) :
    currentFile;
  const json = readJsonFile(file);
  return {file, value: resolveJsonPointer(json, pointer)};
}

function resolveJsonPointer(document, pointer) {
  if (!pointer || pointer === "/") return document;
  if (!pointer.startsWith("/")) {
    throw new Error(`Unsupported JSON pointer: #${pointer}`);
  }
  return pointer
    .slice(1)
    .split("/")
    .reduce((value, token) => {
      const key = token.replace(/~1/g, "/").replace(/~0/g, "~");
      if (value === undefined || value === null ||
          !Object.prototype.hasOwnProperty.call(value, key)) {
        throw new Error(`JSON pointer segment not found: ${key}`);
      }
      return value[key];
    }, document);
}

function stripSchemaMeta(value) {
  if (!value || typeof value !== "object" || Array.isArray(value)) return value;
  const {$schema, $id, ...rest} = value;
  return rest;
}

function readContractJson(relativePath) {
  return readJsonFile(path.join(contractRoot, relativePath));
}

function readJsonFile(file) {
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

function tsGeneratedHeader() {
  return `/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

`;
}

function mjsGeneratedHeader() {
  return `// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

`;
}

function dartGeneratedHeader() {
  return `// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names
`;
}

function jsonForTs(value) {
  return `${JSON.stringify(value, null, 2)} as const`;
}

function jsonForJs(value) {
  return JSON.stringify(value, null, 2);
}

function dartLiteral(value) {
  if (value === null) return "null";
  if (typeof value === "string") return dartString(value);
  if (typeof value === "number" || typeof value === "boolean") {
    return String(value);
  }
  if (Array.isArray(value)) {
    if (value.length === 0) return "<Object?>[]";
    return `<Object?>[
${value.map((item) => indent(dartLiteral(item), 2)).join(",\n")},
]`;
  }
  const entries = Object.entries(value).map(([key, item]) =>
    `${indent(`${dartString(key)}: ${dartLiteral(item)}`, 2)}`
  );
  if (entries.length === 0) return "<String, Object?>{}";
  return `<String, Object?>{
${entries.join(",\n")},
}`;
}

function dartString(value) {
  return `'${String(value)
    .replace(/\\/g, "\\\\")
    .replace(/'/g, "\\'")
    .replace(/\$/g, "\\$")
    .replace(/\r/g, "\\r")
    .replace(/\n/g, "\\n")}'`;
}

function indent(value, spaces) {
  const pad = " ".repeat(spaces);
  return String(value)
    .split("\n")
    .map((line) => `${pad}${line}`)
    .join("\n");
}

await main();
