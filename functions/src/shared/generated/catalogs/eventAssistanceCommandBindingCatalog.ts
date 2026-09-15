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
        ]
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventRehearsal"
        ]
      }
    },
    {
      "commandKind": "setJoinIntent",
      "live": {
        "bindingType": "directCommand",
        "operations": [
          "submitEventAssistanceGuestChoice"
        ]
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "submitEventRehearsalGuestAction"
        ]
      }
    },
    {
      "commandKind": "checkInGuest",
      "live": {
        "bindingType": "domainAdapter",
        "operations": [
          "setEventAttendeeAttendance",
          "checkInEventRuntime"
        ]
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "submitEventRehearsalGuestAction"
        ]
      }
    },
    {
      "commandKind": "publishGuidance",
      "live": {
        "bindingType": "internalCoordinator",
        "operations": [
          "prepareLiveLateJoinPublication"
        ]
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventRehearsal"
        ]
      }
    },
    {
      "commandKind": "sendOperationalMessage",
      "live": {
        "bindingType": "internalCoordinator",
        "operations": [
          "LiveMessageDispatcher.dispatch"
        ]
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventRehearsal"
        ]
      }
    },
    {
      "commandKind": "openHostCase",
      "live": {
        "bindingType": "internalCoordinator",
        "operations": [
          "GuestAssistanceStore.submit"
        ]
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "submitEventRehearsalGuestAction"
        ]
      }
    },
    {
      "commandKind": "setParticipation",
      "live": {
        "bindingType": "directCommand",
        "operations": [
          "setEventAssistanceParticipation"
        ]
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "injectEventRehearsalBehavior"
        ]
      }
    },
    {
      "commandKind": "proposeAllocation",
      "live": {
        "bindingType": "domainAdapter",
        "operations": [
          "generateEventSuccessPods",
          "generateEventSuccessRotations"
        ]
      },
      "rehearsal": {
        "bindingType": "contractOnly",
        "operations": []
      }
    },
    {
      "commandKind": "publishAllocation",
      "live": {
        "bindingType": "domainAdapter",
        "operations": [
          "publishEventSuccessRotationRound"
        ]
      },
      "rehearsal": {
        "bindingType": "contractOnly",
        "operations": []
      }
    },
    {
      "commandKind": "confirmPlacement",
      "live": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventSuccessSpatial",
          "resolveEventSuccessLateArrival"
        ]
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventRehearsalSpatial"
        ]
      }
    },
    {
      "commandKind": "changeResource",
      "live": {
        "bindingType": "domainAdapter",
        "operations": [
          "upsertEventSuccessLayout",
          "controlEventSuccessSpatial"
        ]
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "updateEventRehearsalSetup"
        ]
      }
    },
    {
      "commandKind": "transferGroup",
      "live": {
        "bindingType": "directCommand",
        "operations": [
          "transferEventAssistanceGroup"
        ]
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventRehearsal"
        ]
      }
    },
    {
      "commandKind": "recordCheckpoint",
      "live": {
        "bindingType": "directCommand",
        "operations": [
          "recordEventAssistanceCheckpoint"
        ]
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventRehearsal"
        ]
      }
    },
    {
      "commandKind": "changeProgramme",
      "live": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventSuccessLive"
        ]
      },
      "rehearsal": {
        "bindingType": "contractOnly",
        "operations": []
      }
    },
    {
      "commandKind": "recordOutcome",
      "live": {
        "bindingType": "domainAdapter",
        "operations": [
          "recordEventSuccessUnitOutcomes"
        ]
      },
      "rehearsal": {
        "bindingType": "contractOnly",
        "operations": []
      }
    },
    {
      "commandKind": "changeRoute",
      "live": {
        "bindingType": "contractOnly",
        "operations": []
      },
      "rehearsal": {
        "bindingType": "contractOnly",
        "operations": []
      }
    },
    {
      "commandKind": "resolveAccountability",
      "live": {
        "bindingType": "directCommand",
        "operations": [
          "resolveEventAssistanceAccountability"
        ]
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventRehearsal"
        ]
      }
    },
    {
      "commandKind": "resolveClaim",
      "live": {
        "bindingType": "domainAdapter",
        "operations": [
          "approveEventRuntimeClaim"
        ]
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "injectEventRehearsalBehavior"
        ]
      }
    },
    {
      "commandKind": "admitGuest",
      "live": {
        "bindingType": "domainAdapter",
        "operations": [
          "decideEventJoinRequest"
        ]
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "injectEventRehearsalBehavior"
        ]
      }
    },
    {
      "commandKind": "assignResponsibility",
      "live": {
        "bindingType": "domainAdapter",
        "operations": [
          "setEventAssistanceGroupStaff",
          "grantEventStaff"
        ]
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventRehearsal"
        ]
      }
    },
    {
      "commandKind": "resolveAssistance",
      "live": {
        "bindingType": "directCommand",
        "operations": [
          "resolveEventAssistanceCase"
        ]
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventRehearsal"
        ]
      }
    },
    {
      "commandKind": "reconcileAttendance",
      "live": {
        "bindingType": "contractOnly",
        "operations": []
      },
      "rehearsal": {
        "bindingType": "contractOnly",
        "operations": []
      }
    },
    {
      "commandKind": "requestRequiredData",
      "live": {
        "bindingType": "contractOnly",
        "operations": []
      },
      "rehearsal": {
        "bindingType": "contractOnly",
        "operations": []
      }
    },
    {
      "commandKind": "reconcileRoster",
      "live": {
        "bindingType": "domainAdapter",
        "operations": [
          "ingestEventRosterWebhook"
        ]
      },
      "rehearsal": {
        "bindingType": "contractOnly",
        "operations": []
      }
    },
    {
      "commandKind": "reconcileFinance",
      "live": {
        "bindingType": "contractOnly",
        "operations": []
      },
      "rehearsal": {
        "bindingType": "contractOnly",
        "operations": []
      }
    },
    {
      "commandKind": "repairDelivery",
      "live": {
        "bindingType": "directCommand",
        "operations": [
          "repairEventAssistanceDelivery"
        ]
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventRehearsal"
        ]
      }
    },
    {
      "commandKind": "resumeOperation",
      "live": {
        "bindingType": "contractOnly",
        "operations": []
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventRehearsal"
        ]
      }
    },
    {
      "commandKind": "completeEvent",
      "live": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventSuccessLive"
        ]
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "completeEventRehearsal"
        ]
      }
    },
    {
      "commandKind": "controlUnitProgress",
      "live": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventSuccessLive"
        ]
      },
      "rehearsal": {
        "bindingType": "contractOnly",
        "operations": []
      }
    },
    {
      "commandKind": "controlReveal",
      "live": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventSuccessLive"
        ]
      },
      "rehearsal": {
        "bindingType": "contractOnly",
        "operations": []
      }
    },
    {
      "commandKind": "applyOverride",
      "live": {
        "bindingType": "domainAdapter",
        "operations": [
          "overrideEventSuccessGroups",
          "overrideEventSuccessRotations"
        ]
      },
      "rehearsal": {
        "bindingType": "contractOnly",
        "operations": []
      }
    },
    {
      "commandKind": "setLocationSharing",
      "live": {
        "bindingType": "contractOnly",
        "operations": []
      },
      "rehearsal": {
        "bindingType": "contractOnly",
        "operations": []
      }
    },
    {
      "commandKind": "requestCheckpointReport",
      "live": {
        "bindingType": "internalCoordinator",
        "operations": [
          "AssistanceCheckpointWorkStore.process"
        ]
      },
      "rehearsal": {
        "bindingType": "internalCoordinator",
        "operations": [
          "controlEventRehearsal"
        ]
      }
    },
    {
      "commandKind": "recordNoShow",
      "live": {
        "bindingType": "directCommand",
        "operations": [
          "recordEventNoShow"
        ]
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "injectEventRehearsalBehavior"
        ]
      }
    },
    {
      "commandKind": "routeRestrictedCase",
      "live": {
        "bindingType": "contractOnly",
        "operations": []
      },
      "rehearsal": {
        "bindingType": "contractOnly",
        "operations": []
      }
    },
    {
      "commandKind": "resolveRestrictedCase",
      "live": {
        "bindingType": "contractOnly",
        "operations": []
      },
      "rehearsal": {
        "bindingType": "contractOnly",
        "operations": []
      }
    },
    {
      "commandKind": "reassignCheckpointReporter",
      "live": {
        "bindingType": "directCommand",
        "operations": [
          "reassignEventAssistanceCheckpointReporter"
        ]
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventRehearsal"
        ]
      }
    },
    {
      "commandKind": "setCheckpointCloseout",
      "live": {
        "bindingType": "directCommand",
        "operations": [
          "setEventAssistanceCheckpointCloseout"
        ]
      },
      "rehearsal": {
        "bindingType": "domainAdapter",
        "operations": [
          "controlEventRehearsal"
        ]
      }
    }
  ]
} as const;
