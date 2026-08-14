/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export type EventSuccessMomentKind =
  "none" | "preArrival" | "selfCheckIn" | "firstHelloCheckIn" | "compatibilityQuestionnaire" | "liveStepContext" | "socialPrompt" | "conversationCues" | "assignment" | "liveReveal" | "wingmanRequest" | "postEvent";
export type EventSuccessInteractionModel =
  "pacePods" | "pairedRotations" | "teamRotations" | "seatedTable" | "freeFormMixer" | "hostLedProgram" | "openFormat";
export type EventSuccessDisclosureLevel =
  "light" | "personal" | "reflective";
export type EventSuccessAccentPalettePolicyId =
  "primary" | "secondary" | "secondaryUntilReveal";
export type EventSuccessMomentClockReferenceId =
  "none" | "revealStartedAtPlusStructureRevealCountdown";
export type EventSuccessMomentSeedDerivationRuleId =
  "fnv1a32-utf8-fields-v1";
export type EventSuccessAmbientBedId =
  "theatrical" | "pulse" | "sunrise" | "silent";

export interface EventSuccessMomentPhaseDurations {
  readonly anticipation: number;
  readonly climax: number;
  readonly settle: number;
}

export interface EventSuccessMomentPresentationContract {
  readonly momentKind: EventSuccessMomentKind;
  readonly paletteTokenId: string;
  readonly accentPaletteTokenId: string | null;
  readonly accentPalettePolicyId: EventSuccessAccentPalettePolicyId;
  readonly motifId: string;
  readonly phaseDurationsMs: EventSuccessMomentPhaseDurations;
  readonly tempoBpm: number;
  readonly idlePulsePeriodMs: number;
  readonly particleDensity: number;
  readonly seedDerivationRuleId: EventSuccessMomentSeedDerivationRuleId;
  readonly clockReferenceId: EventSuccessMomentClockReferenceId;
  readonly ambientBedId: EventSuccessAmbientBedId;
  readonly ambientBedWhenEventEndedId: EventSuccessAmbientBedId | null;
}

export interface EventSuccessSocialMissionPromptContract {
  readonly promptId: string;
  readonly disclosureLevel: EventSuccessDisclosureLevel;
}

export interface EventSuccessSocialMissionPromptSetContract {
  readonly interactionModel: EventSuccessInteractionModel;
  readonly prompts: readonly EventSuccessSocialMissionPromptContract[];
}

export interface EventSuccessMomentPresentationCatalog {
  readonly schemaVersion: 1;
  readonly kind: "eventSuccessMomentPresentations";
  readonly moments: readonly EventSuccessMomentPresentationContract[];
  readonly socialMissionPromptSets:
    readonly EventSuccessSocialMissionPromptSetContract[];
  readonly parityFixture: {
    readonly eventId: string;
    readonly momentKind: EventSuccessMomentKind;
    readonly activeRevealRoundIndex: number;
    readonly serverAnchorMillis: number;
    readonly revealCountdownMs: number;
    readonly expected: EventSuccessCeremonyTimeline & {readonly seed: number};
  };
}

export interface EventSuccessCeremonyTimeline {
  readonly anticipationStartsAtMillis: number;
  readonly climaxStartsAtMillis: number;
  readonly settleStartsAtMillis: number;
  readonly completesAtMillis: number;
}

export const eventSuccessMomentPresentationCatalog:
  EventSuccessMomentPresentationCatalog =
  {
  "schemaVersion": 1,
  "kind": "eventSuccessMomentPresentations",
  "moments": [
    {
      "momentKind": "none",
      "paletteTokenId": "editorial.dark",
      "accentPaletteTokenId": null,
      "accentPalettePolicyId": "primary",
      "motifId": "path",
      "phaseDurationsMs": {
        "anticipation": 0,
        "climax": 0,
        "settle": 0
      },
      "tempoBpm": 60,
      "idlePulsePeriodMs": 16000,
      "particleDensity": 0,
      "seedDerivationRuleId": "fnv1a32-utf8-fields-v1",
      "clockReferenceId": "none",
      "ambientBedId": "theatrical",
      "ambientBedWhenEventEndedId": "sunrise"
    },
    {
      "momentKind": "preArrival",
      "paletteTokenId": "activity.running",
      "accentPaletteTokenId": null,
      "accentPalettePolicyId": "primary",
      "motifId": "path",
      "phaseDurationsMs": {
        "anticipation": 0,
        "climax": 0,
        "settle": 0
      },
      "tempoBpm": 60,
      "idlePulsePeriodMs": 16000,
      "particleDensity": 0,
      "seedDerivationRuleId": "fnv1a32-utf8-fields-v1",
      "clockReferenceId": "none",
      "ambientBedId": "theatrical",
      "ambientBedWhenEventEndedId": null
    },
    {
      "momentKind": "selfCheckIn",
      "paletteTokenId": "activity.walking",
      "accentPaletteTokenId": null,
      "accentPalettePolicyId": "primary",
      "motifId": "gate",
      "phaseDurationsMs": {
        "anticipation": 0,
        "climax": 0,
        "settle": 0
      },
      "tempoBpm": 60,
      "idlePulsePeriodMs": 16000,
      "particleDensity": 0,
      "seedDerivationRuleId": "fnv1a32-utf8-fields-v1",
      "clockReferenceId": "none",
      "ambientBedId": "theatrical",
      "ambientBedWhenEventEndedId": null
    },
    {
      "momentKind": "firstHelloCheckIn",
      "paletteTokenId": "activity.pickleball",
      "accentPaletteTokenId": null,
      "accentPalettePolicyId": "primary",
      "motifId": "signal",
      "phaseDurationsMs": {
        "anticipation": 0,
        "climax": 0,
        "settle": 0
      },
      "tempoBpm": 60,
      "idlePulsePeriodMs": 16000,
      "particleDensity": 0,
      "seedDerivationRuleId": "fnv1a32-utf8-fields-v1",
      "clockReferenceId": "none",
      "ambientBedId": "theatrical",
      "ambientBedWhenEventEndedId": null
    },
    {
      "momentKind": "compatibilityQuestionnaire",
      "paletteTokenId": "activity.padel",
      "accentPaletteTokenId": null,
      "accentPalettePolicyId": "primary",
      "motifId": "spark",
      "phaseDurationsMs": {
        "anticipation": 0,
        "climax": 0,
        "settle": 0
      },
      "tempoBpm": 60,
      "idlePulsePeriodMs": 16000,
      "particleDensity": 0,
      "seedDerivationRuleId": "fnv1a32-utf8-fields-v1",
      "clockReferenceId": "none",
      "ambientBedId": "theatrical",
      "ambientBedWhenEventEndedId": null
    },
    {
      "momentKind": "liveStepContext",
      "paletteTokenId": "activity.tennis",
      "accentPaletteTokenId": null,
      "accentPalettePolicyId": "primary",
      "motifId": "rhythm",
      "phaseDurationsMs": {
        "anticipation": 0,
        "climax": 0,
        "settle": 0
      },
      "tempoBpm": 60,
      "idlePulsePeriodMs": 16000,
      "particleDensity": 0,
      "seedDerivationRuleId": "fnv1a32-utf8-fields-v1",
      "clockReferenceId": "none",
      "ambientBedId": "pulse",
      "ambientBedWhenEventEndedId": null
    },
    {
      "momentKind": "socialPrompt",
      "paletteTokenId": "activity.badminton",
      "accentPaletteTokenId": null,
      "accentPalettePolicyId": "primary",
      "motifId": "rhythm",
      "phaseDurationsMs": {
        "anticipation": 0,
        "climax": 0,
        "settle": 0
      },
      "tempoBpm": 60,
      "idlePulsePeriodMs": 16000,
      "particleDensity": 0,
      "seedDerivationRuleId": "fnv1a32-utf8-fields-v1",
      "clockReferenceId": "none",
      "ambientBedId": "pulse",
      "ambientBedWhenEventEndedId": null
    },
    {
      "momentKind": "conversationCues",
      "paletteTokenId": "activity.cycling",
      "accentPaletteTokenId": null,
      "accentPalettePolicyId": "primary",
      "motifId": "rhythm",
      "phaseDurationsMs": {
        "anticipation": 0,
        "climax": 0,
        "settle": 0
      },
      "tempoBpm": 60,
      "idlePulsePeriodMs": 16000,
      "particleDensity": 0,
      "seedDerivationRuleId": "fnv1a32-utf8-fields-v1",
      "clockReferenceId": "none",
      "ambientBedId": "pulse",
      "ambientBedWhenEventEndedId": null
    },
    {
      "momentKind": "assignment",
      "paletteTokenId": "activity.spinClass",
      "accentPaletteTokenId": "activity.dinner",
      "accentPalettePolicyId": "secondary",
      "motifId": "orbit",
      "phaseDurationsMs": {
        "anticipation": 0,
        "climax": 0,
        "settle": 0
      },
      "tempoBpm": 60,
      "idlePulsePeriodMs": 16000,
      "particleDensity": 0,
      "seedDerivationRuleId": "fnv1a32-utf8-fields-v1",
      "clockReferenceId": "none",
      "ambientBedId": "pulse",
      "ambientBedWhenEventEndedId": null
    },
    {
      "momentKind": "liveReveal",
      "paletteTokenId": "activity.yoga",
      "accentPaletteTokenId": "activity.singlesMixer",
      "accentPalettePolicyId": "secondaryUntilReveal",
      "motifId": "reveal",
      "phaseDurationsMs": {
        "anticipation": 10000,
        "climax": 1500,
        "settle": 700
      },
      "tempoBpm": 60,
      "idlePulsePeriodMs": 16000,
      "particleDensity": 72,
      "seedDerivationRuleId": "fnv1a32-utf8-fields-v1",
      "clockReferenceId": "revealStartedAtPlusStructureRevealCountdown",
      "ambientBedId": "silent",
      "ambientBedWhenEventEndedId": null
    },
    {
      "momentKind": "wingmanRequest",
      "paletteTokenId": "activity.strengthTraining",
      "accentPaletteTokenId": null,
      "accentPalettePolicyId": "primary",
      "motifId": "signal",
      "phaseDurationsMs": {
        "anticipation": 0,
        "climax": 0,
        "settle": 0
      },
      "tempoBpm": 60,
      "idlePulsePeriodMs": 16000,
      "particleDensity": 0,
      "seedDerivationRuleId": "fnv1a32-utf8-fields-v1",
      "clockReferenceId": "none",
      "ambientBedId": "pulse",
      "ambientBedWhenEventEndedId": null
    },
    {
      "momentKind": "postEvent",
      "paletteTokenId": "activity.pubQuiz",
      "accentPaletteTokenId": null,
      "accentPalettePolicyId": "primary",
      "motifId": "afterglow",
      "phaseDurationsMs": {
        "anticipation": 0,
        "climax": 0,
        "settle": 0
      },
      "tempoBpm": 60,
      "idlePulsePeriodMs": 16000,
      "particleDensity": 0,
      "seedDerivationRuleId": "fnv1a32-utf8-fields-v1",
      "clockReferenceId": "none",
      "ambientBedId": "sunrise",
      "ambientBedWhenEventEndedId": null
    }
  ],
  "socialMissionPromptSets": [
    {
      "interactionModel": "pacePods",
      "prompts": [
        {
          "promptId": "pacePods.light",
          "disclosureLevel": "light"
        },
        {
          "promptId": "shared.personal",
          "disclosureLevel": "personal"
        },
        {
          "promptId": "shared.reflective",
          "disclosureLevel": "reflective"
        }
      ]
    },
    {
      "interactionModel": "pairedRotations",
      "prompts": [
        {
          "promptId": "pairedRotations.light",
          "disclosureLevel": "light"
        },
        {
          "promptId": "shared.personal",
          "disclosureLevel": "personal"
        },
        {
          "promptId": "shared.reflective",
          "disclosureLevel": "reflective"
        }
      ]
    },
    {
      "interactionModel": "teamRotations",
      "prompts": [
        {
          "promptId": "teamRotations.light",
          "disclosureLevel": "light"
        },
        {
          "promptId": "shared.personal",
          "disclosureLevel": "personal"
        },
        {
          "promptId": "shared.reflective",
          "disclosureLevel": "reflective"
        }
      ]
    },
    {
      "interactionModel": "seatedTable",
      "prompts": [
        {
          "promptId": "seatedTable.light",
          "disclosureLevel": "light"
        },
        {
          "promptId": "shared.personal",
          "disclosureLevel": "personal"
        },
        {
          "promptId": "shared.reflective",
          "disclosureLevel": "reflective"
        }
      ]
    },
    {
      "interactionModel": "freeFormMixer",
      "prompts": [
        {
          "promptId": "freeFormMixer.light",
          "disclosureLevel": "light"
        },
        {
          "promptId": "shared.personal",
          "disclosureLevel": "personal"
        },
        {
          "promptId": "shared.reflective",
          "disclosureLevel": "reflective"
        }
      ]
    },
    {
      "interactionModel": "hostLedProgram",
      "prompts": [
        {
          "promptId": "hostLedProgram.light",
          "disclosureLevel": "light"
        },
        {
          "promptId": "shared.personal",
          "disclosureLevel": "personal"
        },
        {
          "promptId": "shared.reflective",
          "disclosureLevel": "reflective"
        }
      ]
    },
    {
      "interactionModel": "openFormat",
      "prompts": [
        {
          "promptId": "openFormat.light",
          "disclosureLevel": "light"
        },
        {
          "promptId": "shared.personal",
          "disclosureLevel": "personal"
        },
        {
          "promptId": "shared.reflective",
          "disclosureLevel": "reflective"
        }
      ]
    }
  ],
  "parityFixture": {
    "eventId": "event-parity-2026",
    "momentKind": "liveReveal",
    "activeRevealRoundIndex": 2,
    "serverAnchorMillis": 1786703400000,
    "revealCountdownMs": 10000,
    "expected": {
      "anticipationStartsAtMillis": 1786703400000,
      "climaxStartsAtMillis": 1786703410000,
      "settleStartsAtMillis": 1786703411500,
      "completesAtMillis": 1786703412200,
      "seed": 2263797243
    }
  }
} as const;

const eventSuccessMomentPresentationsByKind = new Map<
  EventSuccessMomentKind,
  EventSuccessMomentPresentationContract
>(eventSuccessMomentPresentationCatalog.moments.map((presentation) => [
  presentation.momentKind,
  presentation,
]));

export function eventSuccessMomentPresentationFor(
  momentKind: EventSuccessMomentKind
): EventSuccessMomentPresentationContract {
  const presentation = eventSuccessMomentPresentationsByKind.get(momentKind);
  if (!presentation) {
    throw new Error("Missing Event Success moment presentation: " + momentKind);
  }
  return presentation;
}

const eventSuccessSocialMissionPromptsByInteractionModel = new Map<
  EventSuccessInteractionModel,
  EventSuccessSocialMissionPromptSetContract
>(eventSuccessMomentPresentationCatalog.socialMissionPromptSets.map((set) => [
  set.interactionModel,
  set,
]));

export function eventSuccessSocialMissionPromptFor(input: {
  interactionModel: EventSuccessInteractionModel;
  activeStepIndex: number;
}): EventSuccessSocialMissionPromptContract {
  const promptSet = eventSuccessSocialMissionPromptsByInteractionModel.get(
    input.interactionModel
  );
  if (!promptSet || promptSet.prompts.length !== 3) {
    throw new Error(
      "Missing Event Success social missions: " + input.interactionModel
    );
  }
  const disclosureIndex = Math.max(0, Math.min(2, input.activeStepIndex));
  return promptSet.prompts[disclosureIndex];
}

export function resolveEventSuccessCeremonyTimeline(input: {
  presentation: EventSuccessMomentPresentationContract;
  serverAnchorMillis: number;
  revealCountdownMs?: number | null;
}): EventSuccessCeremonyTimeline {
  const configuredAnticipationMs =
    input.presentation.phaseDurationsMs.anticipation;
  const anticipationDurationMs =
    input.presentation.clockReferenceId ===
      "revealStartedAtPlusStructureRevealCountdown" ?
      input.revealCountdownMs ?? configuredAnticipationMs :
      configuredAnticipationMs;
  if (!Number.isSafeInteger(input.serverAnchorMillis) ||
      !Number.isInteger(anticipationDurationMs) ||
      anticipationDurationMs < 0) {
    throw new Error("Event Success ceremony timing input is invalid.");
  }
  const climaxStartsAtMillis =
    input.serverAnchorMillis + anticipationDurationMs;
  const settleStartsAtMillis =
    climaxStartsAtMillis + input.presentation.phaseDurationsMs.climax;
  return {
    anticipationStartsAtMillis: input.serverAnchorMillis,
    climaxStartsAtMillis,
    settleStartsAtMillis,
    completesAtMillis:
      settleStartsAtMillis + input.presentation.phaseDurationsMs.settle,
  };
}

export function deriveEventSuccessMomentSeed(input: {
  presentation: EventSuccessMomentPresentationContract;
  eventId: string;
  activeRevealRoundIndex: number;
  serverAnchorMillis: number;
}): number {
  if (input.presentation.seedDerivationRuleId !==
      "fnv1a32-utf8-fields-v1") {
    throw new Error(
      "Unsupported Event Success seed rule: " +
        input.presentation.seedDerivationRuleId
    );
  }
  let hash = 0x811c9dc5;
  const fields = [
    input.eventId,
    input.presentation.momentKind,
    String(input.activeRevealRoundIndex),
    String(input.serverAnchorMillis),
  ];
  for (const field of fields) {
    for (const byte of new TextEncoder().encode(field)) {
      hash = Math.imul(hash ^ byte, 0x01000193) >>> 0;
    }
    hash = Math.imul(hash ^ 0xff, 0x01000193) >>> 0;
  }
  return hash;
}
