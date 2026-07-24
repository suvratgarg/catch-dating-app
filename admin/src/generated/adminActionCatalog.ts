// GENERATED FILE. Run: node tool/admin/generate_admin_action_catalog.mjs
export const adminActionCatalog = {
  "schemaVersion": 1,
  "catalogVersion": "1.0.0",
  "actions": [
    {
      "actionId": "overview.get",
      "callable": "adminGetOverview",
      "workflowIds": [
        "overview",
        "safety",
        "access",
        "growth",
        "finance",
        "data-quality"
      ],
      "guiPath": "/overview",
      "kind": "read",
      "risk": "read",
      "roles": [
        "admin",
        "adminOwner",
        "safetyReviewer",
        "support",
        "finance",
        "analyticsViewer"
      ],
      "summary": "Load the bounded admin overview, queue, and data-quality snapshot.",
      "controlPlane": false
    },
    {
      "actionId": "safety.get",
      "callable": "adminGetSafetyTriageDetails",
      "workflowIds": [
        "safety"
      ],
      "guiPath": "/safety",
      "kind": "read",
      "risk": "sensitive-read",
      "roles": [
        "admin",
        "adminOwner",
        "safetyReviewer",
        "support"
      ],
      "summary": "Load one normalized safety-triage item and its bounded evidence.",
      "controlPlane": false
    },
    {
      "actionId": "safety.assign",
      "callable": "adminAssignSafetyTriageItem",
      "workflowIds": [
        "safety"
      ],
      "guiPath": "/safety",
      "kind": "mutation",
      "risk": "high",
      "roles": [
        "admin",
        "adminOwner",
        "safetyReviewer"
      ],
      "summary": "Assign or clear the owner of one safety-triage item.",
      "controlPlane": false
    },
    {
      "actionId": "safety.decide",
      "callable": "adminDecideSafetyTriageItem",
      "workflowIds": [
        "safety"
      ],
      "guiPath": "/safety",
      "kind": "mutation",
      "risk": "critical",
      "roles": [
        "admin",
        "adminOwner",
        "safetyReviewer"
      ],
      "summary": "Record the reviewed or dismissed outcome for one safety item.",
      "controlPlane": false
    },
    {
      "actionId": "access.get",
      "callable": "adminGetAccessApplicationDetails",
      "workflowIds": [
        "access"
      ],
      "guiPath": "/access",
      "kind": "read",
      "risk": "sensitive-read",
      "roles": [
        "admin",
        "adminOwner",
        "support"
      ],
      "summary": "Load one launch-access application and duplicate signals.",
      "controlPlane": false
    },
    {
      "actionId": "access.decide",
      "callable": "adminDecideAccessApplication",
      "workflowIds": [
        "access"
      ],
      "guiPath": "/access",
      "kind": "mutation",
      "risk": "critical",
      "roles": [
        "admin",
        "adminOwner",
        "support"
      ],
      "summary": "Approve or deny one launch-access application.",
      "controlPlane": false
    },
    {
      "actionId": "analytics.host",
      "callable": "adminGetHostAnalytics",
      "workflowIds": [
        "overview",
        "growth",
        "finance",
        "data-quality"
      ],
      "guiPath": "/growth",
      "kind": "read",
      "risk": "sensitive-read",
      "roles": [
        "adminOwner",
        "analyticsViewer"
      ],
      "summary": "Load aggregate host, organizer, or event analytics for a bounded range.",
      "controlPlane": false
    },
    {
      "actionId": "analytics.user",
      "callable": "adminGetUserAnalytics",
      "workflowIds": [
        "users"
      ],
      "guiPath": "/users",
      "kind": "read",
      "risk": "sensitive-read",
      "roles": [
        "adminOwner",
        "analyticsViewer"
      ],
      "summary": "Load the bounded analytics report for one exact user id.",
      "controlPlane": false
    },
    {
      "actionId": "marketing.get",
      "callable": "adminGetMarketingOpsDashboard",
      "workflowIds": [
        "marketing",
        "data-quality"
      ],
      "guiPath": "/marketing",
      "kind": "read",
      "risk": "read",
      "roles": [
        "admin",
        "adminOwner",
        "support"
      ],
      "summary": "Load the current reviewable marketing operations dashboard.",
      "controlPlane": false
    },
    {
      "actionId": "marketing.create-draft",
      "callable": "adminCreateMarketingContentDraft",
      "workflowIds": [
        "marketing"
      ],
      "guiPath": "/marketing/new",
      "kind": "mutation",
      "risk": "high",
      "roles": [
        "admin",
        "adminOwner",
        "support"
      ],
      "summary": "Create one reviewable marketing content draft; this does not post it.",
      "controlPlane": false
    },
    {
      "actionId": "marketing.record-decision",
      "callable": "adminRecordMarketingReviewDecision",
      "workflowIds": [
        "marketing"
      ],
      "guiPath": "/marketing/posts",
      "kind": "mutation",
      "risk": "high",
      "roles": [
        "admin",
        "adminOwner",
        "support"
      ],
      "summary": "Record a bounded review decision for one marketing object; this does not post it.",
      "controlPlane": false
    },
    {
      "actionId": "event-intake.get",
      "callable": "adminGetEventIntakeDashboard",
      "workflowIds": [
        "event-intake",
        "data-quality"
      ],
      "guiPath": "/intake/events",
      "kind": "read",
      "risk": "read",
      "roles": [
        "admin",
        "adminOwner",
        "support"
      ],
      "summary": "Load the current Event Intake bridge and review queues.",
      "controlPlane": false
    },
    {
      "actionId": "event-intake.record-decision",
      "callable": "adminRecordEventIntakeReviewDecision",
      "workflowIds": [
        "event-intake"
      ],
      "guiPath": "/intake/events",
      "kind": "mutation",
      "risk": "high",
      "roles": [
        "admin",
        "adminOwner",
        "support"
      ],
      "summary": "Record one Event Intake review decision without publishing an event.",
      "controlPlane": false
    },
    {
      "actionId": "intake-operations.list",
      "callable": "adminListIntakeOperations",
      "workflowIds": [
        "intake-operations"
      ],
      "guiPath": "/intake/operations",
      "kind": "read",
      "risk": "read",
      "roles": [
        "admin",
        "adminOwner",
        "support"
      ],
      "summary": "List the persisted Supply Intake runs and one bounded item page.",
      "controlPlane": false
    },
    {
      "actionId": "organizer-intake.decide-publication",
      "callable": "adminDecideOrganizerIntake",
      "workflowIds": [
        "organizer-intake"
      ],
      "guiPath": "/intake/organizers",
      "kind": "mutation",
      "risk": "critical",
      "roles": [
        "admin",
        "adminOwner",
        "support"
      ],
      "summary": "Record the manual publication decision for one private organizer candidate.",
      "controlPlane": false
    },
    {
      "actionId": "organizer-intake.decide-event-candidate",
      "callable": "adminDecideOrganizerEventCandidate",
      "workflowIds": [
        "organizer-intake"
      ],
      "guiPath": "/intake/organizers",
      "kind": "mutation",
      "risk": "high",
      "roles": [
        "admin",
        "adminOwner",
        "support"
      ],
      "summary": "Record a review decision for one organizer-sourced event candidate without importing it.",
      "controlPlane": false
    },
    {
      "actionId": "organizer-intake.decide-policy-gap",
      "callable": "adminDecideOrganizerPolicyGap",
      "workflowIds": [
        "organizer-intake"
      ],
      "guiPath": "/intake/organizers",
      "kind": "mutation",
      "risk": "critical",
      "roles": [
        "admin",
        "adminOwner",
        "support"
      ],
      "summary": "Record a policy-gap decision while the underlying behavior remains disabled.",
      "controlPlane": false
    },
    {
      "actionId": "organizer-intake.resolve-location",
      "callable": "adminResolveOrganizerEventLocation",
      "workflowIds": [
        "organizer-intake"
      ],
      "guiPath": "/intake/organizers",
      "kind": "mutation",
      "risk": "high",
      "roles": [
        "admin",
        "adminOwner",
        "support"
      ],
      "summary": "Record reviewed coordinates for one private external event candidate.",
      "controlPlane": false
    },
    {
      "actionId": "organizer-intake.record-curation",
      "callable": "adminRecordOrganizerCuration",
      "workflowIds": [
        "organizer-intake"
      ],
      "guiPath": "/intake/organizers",
      "kind": "mutation",
      "risk": "high",
      "roles": [
        "admin",
        "adminOwner",
        "support"
      ],
      "summary": "Record one atomic organizer curation operation.",
      "controlPlane": false
    },
    {
      "actionId": "organizer-claims.list",
      "callable": "adminListClubClaimRequests",
      "workflowIds": [
        "organizer-claims"
      ],
      "guiPath": "/organizers/claims",
      "kind": "read",
      "risk": "sensitive-read",
      "roles": [
        "admin",
        "adminOwner",
        "support"
      ],
      "summary": "List the bounded organizer-claim review queue.",
      "controlPlane": false
    },
    {
      "actionId": "organizer-claims.get",
      "callable": "adminGetClubClaimRequestDetails",
      "workflowIds": [
        "organizer-claims"
      ],
      "guiPath": "/organizers/claims",
      "kind": "read",
      "risk": "sensitive-read",
      "roles": [
        "admin",
        "adminOwner",
        "support"
      ],
      "summary": "Load one organizer-claim request and its proof references.",
      "controlPlane": false
    },
    {
      "actionId": "organizer-claims.decide",
      "callable": "adminDecideClubClaim",
      "workflowIds": [
        "organizer-claims"
      ],
      "guiPath": "/organizers/claims",
      "kind": "mutation",
      "risk": "critical",
      "roles": [
        "admin",
        "adminOwner",
        "support"
      ],
      "summary": "Approve or reject one organizer claim request.",
      "controlPlane": false
    },
    {
      "actionId": "organizers.list",
      "callable": "adminListOrganizerDetails",
      "workflowIds": [
        "organizers"
      ],
      "guiPath": "/organizers",
      "kind": "read",
      "risk": "read",
      "roles": [
        "admin",
        "adminOwner",
        "support"
      ],
      "summary": "List bounded canonical organizer profiles.",
      "controlPlane": false
    },
    {
      "actionId": "organizers.get",
      "callable": "adminGetOrganizerDetails",
      "workflowIds": [
        "organizers"
      ],
      "guiPath": "/organizers",
      "kind": "read",
      "risk": "read",
      "roles": [
        "admin",
        "adminOwner",
        "support"
      ],
      "summary": "Load one canonical organizer profile and publication state.",
      "controlPlane": false
    },
    {
      "actionId": "organizers.update",
      "callable": "adminUpdateOrganizerDetails",
      "workflowIds": [
        "organizers"
      ],
      "guiPath": "/organizers",
      "kind": "mutation",
      "risk": "critical",
      "roles": [
        "admin",
        "adminOwner",
        "support"
      ],
      "summary": "Patch owner-safe fields on one canonical organizer profile.",
      "controlPlane": false
    },
    {
      "actionId": "organizers.set-index-status",
      "callable": "adminSetClubIndexStatus",
      "workflowIds": [
        "organizers"
      ],
      "guiPath": "/organizers",
      "kind": "mutation",
      "risk": "critical",
      "roles": [
        "admin",
        "adminOwner",
        "support"
      ],
      "summary": "Set one organizer compatibility profile's index-readiness state.",
      "controlPlane": false
    },
    {
      "actionId": "events.list",
      "callable": "adminListEventDetails",
      "workflowIds": [
        "events"
      ],
      "guiPath": "/events",
      "kind": "read",
      "risk": "read",
      "roles": [
        "admin",
        "adminOwner",
        "support"
      ],
      "summary": "List bounded canonical events.",
      "controlPlane": false
    },
    {
      "actionId": "events.get",
      "callable": "adminGetEventDetails",
      "workflowIds": [
        "events"
      ],
      "guiPath": "/events",
      "kind": "read",
      "risk": "read",
      "roles": [
        "admin",
        "adminOwner",
        "support"
      ],
      "summary": "Load one canonical event profile and publication state.",
      "controlPlane": false
    },
    {
      "actionId": "events.update",
      "callable": "adminUpdateEventDetails",
      "workflowIds": [
        "events"
      ],
      "guiPath": "/events",
      "kind": "mutation",
      "risk": "critical",
      "roles": [
        "admin",
        "adminOwner",
        "support"
      ],
      "summary": "Patch owner-safe fields on one canonical event.",
      "controlPlane": false
    },
    {
      "actionId": "external-events.list",
      "callable": "adminListExternalEventDetails",
      "workflowIds": [
        "external-events"
      ],
      "guiPath": "/events/external",
      "kind": "read",
      "risk": "read",
      "roles": [
        "admin",
        "adminOwner",
        "support"
      ],
      "summary": "List bounded read-only external event supply.",
      "controlPlane": false
    },
    {
      "actionId": "external-events.readiness",
      "callable": "adminGetEventSupplyReadiness",
      "workflowIds": [
        "external-events",
        "data-quality"
      ],
      "guiPath": "/events/readiness",
      "kind": "read",
      "risk": "read",
      "roles": [
        "admin",
        "adminOwner",
        "support"
      ],
      "summary": "Load the reviewed external-event import preflight and execution plan.",
      "controlPlane": false
    },
    {
      "actionId": "external-events.publish",
      "callable": "adminPublishExternalEvent",
      "workflowIds": [
        "external-events"
      ],
      "guiPath": "/events/readiness",
      "kind": "mutation",
      "risk": "critical",
      "roles": [
        "admin",
        "adminOwner",
        "support"
      ],
      "summary": "Publish one preflight-approved read-only external event.",
      "controlPlane": false
    },
    {
      "actionId": "admin-roles.list",
      "callable": "adminListAdminRoleAssignments",
      "workflowIds": [
        "admin-roles"
      ],
      "guiPath": "/admin-roles",
      "kind": "read",
      "risk": "sensitive-read",
      "roles": [
        "adminOwner"
      ],
      "summary": "List the bounded admin-role assignment register.",
      "controlPlane": false
    },
    {
      "actionId": "admin-roles.get",
      "callable": "adminGetAdminUserRoles",
      "workflowIds": [
        "admin-roles"
      ],
      "guiPath": "/admin-roles",
      "kind": "read",
      "risk": "sensitive-read",
      "roles": [
        "adminOwner"
      ],
      "summary": "Load the Catch admin roles assigned to one exact Firebase uid.",
      "controlPlane": false
    },
    {
      "actionId": "admin-roles.set",
      "callable": "adminSetAdminUserRoles",
      "workflowIds": [
        "admin-roles"
      ],
      "guiPath": "/admin-roles",
      "kind": "mutation",
      "risk": "critical",
      "roles": [
        "adminOwner"
      ],
      "summary": "Replace the complete Catch admin-role set for one Firebase uid.",
      "controlPlane": false
    },
    {
      "actionId": "operations.list-executions",
      "callable": "adminListActionExecutions",
      "workflowIds": [
        "agent-activity"
      ],
      "guiPath": "/operations",
      "kind": "read",
      "risk": "sensitive-read",
      "roles": [
        "admin",
        "adminOwner",
        "support"
      ],
      "summary": "List bounded agent/CLI action executions for GUI monitoring.",
      "controlPlane": false
    },
    {
      "actionId": "operations.record-execution",
      "callable": "adminRecordActionExecution",
      "workflowIds": [],
      "guiPath": "/operations",
      "kind": "control",
      "risk": "high",
      "roles": [
        "admin",
        "adminOwner",
        "safetyReviewer",
        "support",
        "finance",
        "analyticsViewer"
      ],
      "summary": "Create or advance the remotely visible receipt for one CLI action execution.",
      "controlPlane": true
    }
  ],
  "workflows": [
    {
      "workflowId": "overview",
      "label": "Overview",
      "guiPath": "/overview",
      "actions": [
        "overview.get",
        "analytics.host"
      ]
    },
    {
      "workflowId": "safety",
      "label": "Safety triage",
      "guiPath": "/safety",
      "actions": [
        "overview.get",
        "safety.get",
        "safety.assign",
        "safety.decide"
      ]
    },
    {
      "workflowId": "access",
      "label": "Access review",
      "guiPath": "/access",
      "actions": [
        "overview.get",
        "access.get",
        "access.decide"
      ]
    },
    {
      "workflowId": "growth",
      "label": "Growth",
      "guiPath": "/growth",
      "actions": [
        "overview.get",
        "analytics.host"
      ]
    },
    {
      "workflowId": "marketing",
      "label": "Marketing",
      "guiPath": "/marketing",
      "actions": [
        "marketing.get",
        "marketing.create-draft",
        "marketing.record-decision"
      ]
    },
    {
      "workflowId": "event-intake",
      "label": "Event Intake",
      "guiPath": "/intake/events",
      "actions": [
        "event-intake.get",
        "event-intake.record-decision"
      ]
    },
    {
      "workflowId": "organizer-intake",
      "label": "Organizer Intake",
      "guiPath": "/intake/organizers",
      "actions": [
        "organizer-intake.record-curation",
        "organizer-intake.resolve-location",
        "organizer-intake.decide-event-candidate",
        "organizer-intake.decide-policy-gap",
        "organizer-intake.decide-publication"
      ]
    },
    {
      "workflowId": "intake-operations",
      "label": "Intake Operations",
      "guiPath": "/intake/operations",
      "actions": [
        "intake-operations.list"
      ]
    },
    {
      "workflowId": "organizer-claims",
      "label": "Organizer claims",
      "guiPath": "/organizers/claims",
      "actions": [
        "organizer-claims.list",
        "organizer-claims.get",
        "organizer-claims.decide"
      ]
    },
    {
      "workflowId": "organizers",
      "label": "Organizers",
      "guiPath": "/organizers",
      "actions": [
        "organizers.list",
        "organizers.get",
        "organizers.update",
        "organizers.set-index-status"
      ]
    },
    {
      "workflowId": "events",
      "label": "Events",
      "guiPath": "/events",
      "actions": [
        "events.list",
        "events.get",
        "events.update"
      ]
    },
    {
      "workflowId": "external-events",
      "label": "External events",
      "guiPath": "/events/external",
      "actions": [
        "external-events.list",
        "external-events.readiness",
        "external-events.publish"
      ]
    },
    {
      "workflowId": "users",
      "label": "Users",
      "guiPath": "/users",
      "actions": [
        "analytics.user"
      ]
    },
    {
      "workflowId": "finance",
      "label": "Finance",
      "guiPath": "/finance",
      "actions": [
        "overview.get",
        "analytics.host"
      ],
      "blockedCapabilities": [
        "retry_payment",
        "refund",
        "payout_mutation",
        "settlement_mutation"
      ]
    },
    {
      "workflowId": "data-quality",
      "label": "Data quality",
      "guiPath": "/quality",
      "actions": [
        "overview.get",
        "analytics.host",
        "marketing.get",
        "event-intake.get",
        "external-events.readiness"
      ]
    },
    {
      "workflowId": "admin-roles",
      "label": "Admin roles",
      "guiPath": "/admin-roles",
      "actions": [
        "admin-roles.list",
        "admin-roles.get",
        "admin-roles.set"
      ]
    },
    {
      "workflowId": "agent-activity",
      "label": "Agent activity",
      "guiPath": "/operations",
      "actions": [
        "operations.list-executions"
      ]
    }
  ]
} as const;

export type AdminActionId = typeof adminActionCatalog.actions[number]["actionId"];
