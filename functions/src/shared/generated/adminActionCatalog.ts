// GENERATED FILE. Run: node tool/admin/generate_admin_action_catalog.mjs
export const ADMIN_ACTION_CATALOG = {
  "overview.get": {
    "callable": "adminGetOverview",
    "controlPlane": false,
    "kind": "read",
    "roles": [
      "admin",
      "adminOwner",
      "safetyReviewer",
      "support",
      "finance",
      "analyticsViewer"
    ]
  },
  "safety.get": {
    "callable": "adminGetSafetyTriageDetails",
    "controlPlane": false,
    "kind": "read",
    "roles": [
      "admin",
      "adminOwner",
      "safetyReviewer",
      "support"
    ]
  },
  "safety.assign": {
    "callable": "adminAssignSafetyTriageItem",
    "controlPlane": false,
    "kind": "mutation",
    "roles": [
      "admin",
      "adminOwner",
      "safetyReviewer"
    ]
  },
  "safety.decide": {
    "callable": "adminDecideSafetyTriageItem",
    "controlPlane": false,
    "kind": "mutation",
    "roles": [
      "admin",
      "adminOwner",
      "safetyReviewer"
    ]
  },
  "access.get": {
    "callable": "adminGetAccessApplicationDetails",
    "controlPlane": false,
    "kind": "read",
    "roles": [
      "admin",
      "adminOwner",
      "support"
    ]
  },
  "access.decide": {
    "callable": "adminDecideAccessApplication",
    "controlPlane": false,
    "kind": "mutation",
    "roles": [
      "admin",
      "adminOwner",
      "support"
    ]
  },
  "analytics.host": {
    "callable": "adminGetHostAnalytics",
    "controlPlane": false,
    "kind": "read",
    "roles": [
      "adminOwner",
      "analyticsViewer"
    ]
  },
  "analytics.user": {
    "callable": "adminGetUserAnalytics",
    "controlPlane": false,
    "kind": "read",
    "roles": [
      "adminOwner",
      "analyticsViewer"
    ]
  },
  "marketing.get": {
    "callable": "adminGetMarketingOpsDashboard",
    "controlPlane": false,
    "kind": "read",
    "roles": [
      "admin",
      "adminOwner",
      "support"
    ]
  },
  "marketing.create-draft": {
    "callable": "adminCreateMarketingContentDraft",
    "controlPlane": false,
    "kind": "mutation",
    "roles": [
      "admin",
      "adminOwner",
      "support"
    ]
  },
  "marketing.record-decision": {
    "callable": "adminRecordMarketingReviewDecision",
    "controlPlane": false,
    "kind": "mutation",
    "roles": [
      "admin",
      "adminOwner",
      "support"
    ]
  },
  "event-intake.get": {
    "callable": "adminGetEventIntakeDashboard",
    "controlPlane": false,
    "kind": "read",
    "roles": [
      "admin",
      "adminOwner",
      "support"
    ]
  },
  "event-intake.record-decision": {
    "callable": "adminRecordEventIntakeReviewDecision",
    "controlPlane": false,
    "kind": "mutation",
    "roles": [
      "admin",
      "adminOwner",
      "support"
    ]
  },
  "intake-operations.list": {
    "callable": "adminListIntakeOperations",
    "controlPlane": false,
    "kind": "read",
    "roles": [
      "admin",
      "adminOwner",
      "support"
    ]
  },
  "organizer-intake.decide-publication": {
    "callable": "adminDecideOrganizerIntake",
    "controlPlane": false,
    "kind": "mutation",
    "roles": [
      "admin",
      "adminOwner",
      "support"
    ]
  },
  "organizer-intake.decide-event-candidate": {
    "callable": "adminDecideOrganizerEventCandidate",
    "controlPlane": false,
    "kind": "mutation",
    "roles": [
      "admin",
      "adminOwner",
      "support"
    ]
  },
  "organizer-intake.decide-policy-gap": {
    "callable": "adminDecideOrganizerPolicyGap",
    "controlPlane": false,
    "kind": "mutation",
    "roles": [
      "admin",
      "adminOwner",
      "support"
    ]
  },
  "organizer-intake.resolve-location": {
    "callable": "adminResolveOrganizerEventLocation",
    "controlPlane": false,
    "kind": "mutation",
    "roles": [
      "admin",
      "adminOwner",
      "support"
    ]
  },
  "organizer-intake.record-curation": {
    "callable": "adminRecordOrganizerCuration",
    "controlPlane": false,
    "kind": "mutation",
    "roles": [
      "admin",
      "adminOwner",
      "support"
    ]
  },
  "organizer-claims.list": {
    "callable": "adminListClubClaimRequests",
    "controlPlane": false,
    "kind": "read",
    "roles": [
      "admin",
      "adminOwner",
      "support"
    ]
  },
  "organizer-claims.get": {
    "callable": "adminGetClubClaimRequestDetails",
    "controlPlane": false,
    "kind": "read",
    "roles": [
      "admin",
      "adminOwner",
      "support"
    ]
  },
  "organizer-claims.decide": {
    "callable": "adminDecideClubClaim",
    "controlPlane": false,
    "kind": "mutation",
    "roles": [
      "admin",
      "adminOwner",
      "support"
    ]
  },
  "organizers.list": {
    "callable": "adminListOrganizerDetails",
    "controlPlane": false,
    "kind": "read",
    "roles": [
      "admin",
      "adminOwner",
      "support"
    ]
  },
  "organizers.get": {
    "callable": "adminGetOrganizerDetails",
    "controlPlane": false,
    "kind": "read",
    "roles": [
      "admin",
      "adminOwner",
      "support"
    ]
  },
  "organizers.update": {
    "callable": "adminUpdateOrganizerDetails",
    "controlPlane": false,
    "kind": "mutation",
    "roles": [
      "admin",
      "adminOwner",
      "support"
    ]
  },
  "organizers.set-index-status": {
    "callable": "adminSetClubIndexStatus",
    "controlPlane": false,
    "kind": "mutation",
    "roles": [
      "admin",
      "adminOwner",
      "support"
    ]
  },
  "events.list": {
    "callable": "adminListEventDetails",
    "controlPlane": false,
    "kind": "read",
    "roles": [
      "admin",
      "adminOwner",
      "support"
    ]
  },
  "events.get": {
    "callable": "adminGetEventDetails",
    "controlPlane": false,
    "kind": "read",
    "roles": [
      "admin",
      "adminOwner",
      "support"
    ]
  },
  "events.update": {
    "callable": "adminUpdateEventDetails",
    "controlPlane": false,
    "kind": "mutation",
    "roles": [
      "admin",
      "adminOwner",
      "support"
    ]
  },
  "external-events.list": {
    "callable": "adminListExternalEventDetails",
    "controlPlane": false,
    "kind": "read",
    "roles": [
      "admin",
      "adminOwner",
      "support"
    ]
  },
  "external-events.readiness": {
    "callable": "adminGetEventSupplyReadiness",
    "controlPlane": false,
    "kind": "read",
    "roles": [
      "admin",
      "adminOwner",
      "support"
    ]
  },
  "external-events.publish": {
    "callable": "adminPublishExternalEvent",
    "controlPlane": false,
    "kind": "mutation",
    "roles": [
      "admin",
      "adminOwner",
      "support"
    ]
  },
  "admin-roles.list": {
    "callable": "adminListAdminRoleAssignments",
    "controlPlane": false,
    "kind": "read",
    "roles": [
      "adminOwner"
    ]
  },
  "admin-roles.get": {
    "callable": "adminGetAdminUserRoles",
    "controlPlane": false,
    "kind": "read",
    "roles": [
      "adminOwner"
    ]
  },
  "admin-roles.set": {
    "callable": "adminSetAdminUserRoles",
    "controlPlane": false,
    "kind": "mutation",
    "roles": [
      "adminOwner"
    ]
  },
  "operations.list-executions": {
    "callable": "adminListActionExecutions",
    "controlPlane": false,
    "kind": "read",
    "roles": [
      "admin",
      "adminOwner",
      "support"
    ]
  },
  "operations.record-execution": {
    "callable": "adminRecordActionExecution",
    "controlPlane": true,
    "kind": "control",
    "roles": [
      "admin",
      "adminOwner",
      "safetyReviewer",
      "support",
      "finance",
      "analyticsViewer"
    ]
  }
} as const;

export type AdminActionId = keyof typeof ADMIN_ACTION_CATALOG;
