/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceCommandBindingCatalog = {
  "schemaVersion": 1,
  "kind": "eventAssistanceCommandBindings",
  "definitions": [
    {
      "commandKind": "confirmDeparture",
      "live": {
        "bindingType": "directCommand",
        "operations": [
          "confirmEventAssistanceDeparture"
        ],
        "missingCapability": null
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventRehearsal"
        ],
        "missingCapability": null
      }
    },
    {
      "commandKind": "setJoinIntent",
      "live": {
        "bindingType": "directCommand",
        "operations": [
          "submitEventAssistanceGuestChoice"
        ],
        "missingCapability": null
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "submitEventRehearsalGuestAction"
        ],
        "missingCapability": null
      }
    },
    {
      "commandKind": "checkInGuest",
      "live": {
        "bindingType": "domainAdapter",
        "operations": [
          "setEventAttendeeAttendance",
          "checkInEventRuntime"
        ],
        "missingCapability": null
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "submitEventRehearsalGuestAction"
        ],
        "missingCapability": null
      }
    },
    {
      "commandKind": "publishGuidance",
      "live": {
        "bindingType": "internalCoordinator",
        "operations": [
          "prepareLiveLateJoinPublication"
        ],
        "missingCapability": null
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventRehearsal"
        ],
        "missingCapability": null
      }
    },
    {
      "commandKind": "sendOperationalMessage",
      "live": {
        "bindingType": "internalCoordinator",
        "operations": [
          "LiveMessageDispatcher.dispatch"
        ],
        "missingCapability": null
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventRehearsal"
        ],
        "missingCapability": null
      }
    },
    {
      "commandKind": "openHostCase",
      "live": {
        "bindingType": "internalCoordinator",
        "operations": [
          "GuestAssistanceStore.submit"
        ],
        "missingCapability": null
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "submitEventRehearsalGuestAction"
        ],
        "missingCapability": null
      }
    },
    {
      "commandKind": "setParticipation",
      "live": {
        "bindingType": "directCommand",
        "operations": [
          "setEventAssistanceParticipation"
        ],
        "missingCapability": null
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "injectEventRehearsalBehavior"
        ],
        "missingCapability": null
      }
    },
    {
      "commandKind": "proposeAllocation",
      "live": {
        "bindingType": "domainAdapter",
        "operations": [
          "generateEventSuccessPods",
          "generateEventSuccessRotations"
        ],
        "missingCapability": null
      },
      "rehearsal": {
        "bindingType": "contractOnly",
        "operations": [],
        "missingCapability": "rehearsalAllocationProposal"
      }
    },
    {
      "commandKind": "publishAllocation",
      "live": {
        "bindingType": "domainAdapter",
        "operations": [
          "publishEventSuccessRotationRound"
        ],
        "missingCapability": null
      },
      "rehearsal": {
        "bindingType": "contractOnly",
        "operations": [],
        "missingCapability": "rehearsalAllocationPublication"
      }
    },
    {
      "commandKind": "confirmPlacement",
      "live": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventSuccessSpatial",
          "resolveEventSuccessLateArrival"
        ],
        "missingCapability": null
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventRehearsalSpatial"
        ],
        "missingCapability": null
      }
    },
    {
      "commandKind": "changeResource",
      "live": {
        "bindingType": "domainAdapter",
        "operations": [
          "upsertEventSuccessLayout",
          "controlEventSuccessSpatial"
        ],
        "missingCapability": null
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "updateEventRehearsalSetup"
        ],
        "missingCapability": null
      }
    },
    {
      "commandKind": "transferGroup",
      "live": {
        "bindingType": "directCommand",
        "operations": [
          "transferEventAssistanceGroup"
        ],
        "missingCapability": null
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventRehearsal"
        ],
        "missingCapability": null
      }
    },
    {
      "commandKind": "recordCheckpoint",
      "live": {
        "bindingType": "directCommand",
        "operations": [
          "recordEventAssistanceCheckpoint"
        ],
        "missingCapability": null
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventRehearsal"
        ],
        "missingCapability": null
      }
    },
    {
      "commandKind": "changeProgramme",
      "live": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventSuccessLive"
        ],
        "missingCapability": null
      },
      "rehearsal": {
        "bindingType": "contractOnly",
        "operations": [],
        "missingCapability": "rehearsalProgrammeControl"
      }
    },
    {
      "commandKind": "recordOutcome",
      "live": {
        "bindingType": "domainAdapter",
        "operations": [
          "recordEventSuccessUnitOutcomes"
        ],
        "missingCapability": null
      },
      "rehearsal": {
        "bindingType": "contractOnly",
        "operations": [],
        "missingCapability": "rehearsalOutcomeRecording"
      }
    },
    {
      "commandKind": "changeRoute",
      "live": {
        "bindingType": "contractOnly",
        "operations": [],
        "missingCapability": "liveRouteDecision"
      },
      "rehearsal": {
        "bindingType": "contractOnly",
        "operations": [],
        "missingCapability": "rehearsalRouteDecision"
      }
    },
    {
      "commandKind": "resolveAccountability",
      "live": {
        "bindingType": "directCommand",
        "operations": [
          "resolveEventAssistanceAccountability"
        ],
        "missingCapability": null
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventRehearsal"
        ],
        "missingCapability": null
      }
    },
    {
      "commandKind": "resolveClaim",
      "live": {
        "bindingType": "domainAdapter",
        "operations": [
          "approveEventRuntimeClaim"
        ],
        "missingCapability": null
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "injectEventRehearsalBehavior"
        ],
        "missingCapability": null
      }
    },
    {
      "commandKind": "admitGuest",
      "live": {
        "bindingType": "domainAdapter",
        "operations": [
          "decideEventJoinRequest"
        ],
        "missingCapability": null
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "injectEventRehearsalBehavior"
        ],
        "missingCapability": null
      }
    },
    {
      "commandKind": "assignResponsibility",
      "live": {
        "bindingType": "domainAdapter",
        "operations": [
          "setEventAssistanceGroupStaff",
          "grantEventStaff"
        ],
        "missingCapability": null
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventRehearsal"
        ],
        "missingCapability": null
      }
    },
    {
      "commandKind": "resolveAssistance",
      "live": {
        "bindingType": "directCommand",
        "operations": [
          "resolveEventAssistanceCase"
        ],
        "missingCapability": null
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventRehearsal"
        ],
        "missingCapability": null
      }
    },
    {
      "commandKind": "reconcileAttendance",
      "live": {
        "bindingType": "domainAdapter",
        "operations": [
          "getEventAttendanceDisposition",
          "setEventAttendeeAttendance",
          "recordEventNoShow"
        ],
        "missingCapability": null
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "completeEventRehearsal",
          "injectEventRehearsalBehavior"
        ],
        "missingCapability": null
      }
    },
    {
      "commandKind": "requestRequiredData",
      "live": {
        "bindingType": "contractOnly",
        "operations": [],
        "missingCapability": "liveRequiredDataRequest"
      },
      "rehearsal": {
        "bindingType": "contractOnly",
        "operations": [],
        "missingCapability": "rehearsalRequiredDataRequest"
      }
    },
    {
      "commandKind": "reconcileRoster",
      "live": {
        "bindingType": "domainAdapter",
        "operations": [
          "ingestEventRosterWebhook"
        ],
        "missingCapability": null
      },
      "rehearsal": {
        "bindingType": "contractOnly",
        "operations": [],
        "missingCapability": "rehearsalRosterReconciliation"
      }
    },
    {
      "commandKind": "reconcileFinance",
      "live": {
        "bindingType": "contractOnly",
        "operations": [],
        "missingCapability": "eventPaymentCaseResolution"
      },
      "rehearsal": {
        "bindingType": "contractOnly",
        "operations": [],
        "missingCapability": "rehearsalFinanceReconciliation"
      }
    },
    {
      "commandKind": "repairDelivery",
      "live": {
        "bindingType": "directCommand",
        "operations": [
          "repairEventAssistanceDelivery"
        ],
        "missingCapability": null
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventRehearsal"
        ],
        "missingCapability": null
      }
    },
    {
      "commandKind": "resumeOperation",
      "live": {
        "bindingType": "internalCoordinator",
        "operations": [
          "AssistanceSourceWorkStore.process",
          "AssistanceDeliveryWorkStore.process",
          "AssistanceCheckpointWorkStore.process"
        ],
        "missingCapability": null
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventRehearsal"
        ],
        "missingCapability": null
      }
    },
    {
      "commandKind": "completeEvent",
      "live": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventSuccessLive"
        ],
        "missingCapability": null
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "completeEventRehearsal"
        ],
        "missingCapability": null
      }
    },
    {
      "commandKind": "controlUnitProgress",
      "live": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventSuccessLive"
        ],
        "missingCapability": null
      },
      "rehearsal": {
        "bindingType": "contractOnly",
        "operations": [],
        "missingCapability": "rehearsalUnitProgressControl"
      }
    },
    {
      "commandKind": "controlReveal",
      "live": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventSuccessLive"
        ],
        "missingCapability": null
      },
      "rehearsal": {
        "bindingType": "contractOnly",
        "operations": [],
        "missingCapability": "rehearsalRevealControl"
      }
    },
    {
      "commandKind": "applyOverride",
      "live": {
        "bindingType": "domainAdapter",
        "operations": [
          "overrideEventSuccessGroups",
          "overrideEventSuccessRotations"
        ],
        "missingCapability": null
      },
      "rehearsal": {
        "bindingType": "contractOnly",
        "operations": [],
        "missingCapability": "rehearsalOverrideControl"
      }
    },
    {
      "commandKind": "setLocationSharing",
      "live": {
        "bindingType": "domainAdapter",
        "operations": [
          "publishEventLivePosition"
        ],
        "missingCapability": null
      },
      "rehearsal": {
        "bindingType": "contractOnly",
        "operations": [],
        "missingCapability": "rehearsalLocationSharing"
      }
    },
    {
      "commandKind": "requestCheckpointReport",
      "live": {
        "bindingType": "internalCoordinator",
        "operations": [
          "AssistanceCheckpointWorkStore.process"
        ],
        "missingCapability": null
      },
      "rehearsal": {
        "bindingType": "internalCoordinator",
        "operations": [
          "controlEventRehearsal"
        ],
        "missingCapability": null
      }
    },
    {
      "commandKind": "recordNoShow",
      "live": {
        "bindingType": "directCommand",
        "operations": [
          "recordEventNoShow"
        ],
        "missingCapability": null
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "injectEventRehearsalBehavior"
        ],
        "missingCapability": null
      }
    },
    {
      "commandKind": "routeRestrictedCase",
      "live": {
        "bindingType": "internalCoordinator",
        "operations": [
          "GuestAssistanceStore.submit"
        ],
        "missingCapability": null
      },
      "rehearsal": {
        "bindingType": "contractOnly",
        "operations": [],
        "missingCapability": "rehearsalRestrictedCaseRouting"
      }
    },
    {
      "commandKind": "resolveRestrictedCase",
      "live": {
        "bindingType": "domainAdapter",
        "operations": [
          "adminDecideSafetyTriageItem"
        ],
        "missingCapability": null
      },
      "rehearsal": {
        "bindingType": "contractOnly",
        "operations": [],
        "missingCapability": "rehearsalRestrictedCaseResolution"
      }
    },
    {
      "commandKind": "reassignCheckpointReporter",
      "live": {
        "bindingType": "directCommand",
        "operations": [
          "reassignEventAssistanceCheckpointReporter"
        ],
        "missingCapability": null
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventRehearsal"
        ],
        "missingCapability": null
      }
    },
    {
      "commandKind": "setCheckpointCloseout",
      "live": {
        "bindingType": "directCommand",
        "operations": [
          "setEventAssistanceCheckpointCloseout"
        ],
        "missingCapability": null
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventRehearsal"
        ],
        "missingCapability": null
      }
    }
  ]
} as const;
