/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const programGuestGroupDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/program_guest_groups.schema.json",
  "title": "ProgramGuestGroupDocument",
  "description": "Server-owned organizer-defined guest grouping for a program. Guests carry groupIds[] on their own documents — that array is membership truth; the group document carries the queryable label, dimension, and denormalized memberCount used for headcount cuts, room allocation, and group-targeted Moments. Dimensions are free-form keys suggested per program kind (weddings: side/lineage/relation; corporate: company/delegation/country); labels are always organizer-defined. The wedding couple-side axis remains programHouseholds.side with organizerPrograms.householdSideLabels; groups are the general mechanism for every other cut.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "programGuestGroups",
  "x-firestore-path": "programGuestGroups/{groupId}",
  "x-document-id-field": "groupId",
  "x-owner": "program guest management and reviewed conversion callables",
  "required": [
    "programId",
    "organizerId",
    "label",
    "dimension",
    "sortOrder",
    "memberCount",
    "hotelId",
    "createdAt",
    "updatedAt",
    "revision"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "label": {
      "type": "string",
      "minLength": 1,
      "maxLength": 140,
      "description": "Organizer-defined display label, e.g. \"Sharma family\" or \"Acme delegation\"."
    },
    "dimension": {
      "type": "string",
      "minLength": 1,
      "maxLength": 60,
      "description": "Grouping axis key. Conventional values per program kind (weddings: side/lineage/relation; corporate: company/delegation/country); other keys are allowed so organizers can model arbitrary cuts."
    },
    "sortOrder": {
      "type": "integer",
      "minimum": 0,
      "maximum": 10000,
      "description": "Organizer-controlled ordering within a dimension; lower sorts first."
    },
    "memberCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100000,
      "description": "Denormalized count of programGuests documents whose groupIds contain this group. Maintained transactionally by guest upsert, manifest import, and group delete."
    },
    "hotelId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180,
      "description": "Optional programHotels link: where members of this group stay. Distance-aware moment lead times (audience.travelTimeLead) resolve each guest to the hotel of their first hotel-linked group."
    },
    "createdAt": {
      "type": "object",
      "description": "Serialized Firestore Timestamp fixture shape.",
      "x-firestore-type": "timestamp",
      "additionalProperties": false,
      "required": [
        "_seconds",
        "_nanoseconds"
      ],
      "properties": {
        "_seconds": {
          "type": "integer"
        },
        "_nanoseconds": {
          "type": "integer",
          "minimum": 0,
          "maximum": 999999999
        }
      }
    },
    "updatedAt": {
      "type": "object",
      "description": "Serialized Firestore Timestamp fixture shape.",
      "x-firestore-type": "timestamp",
      "additionalProperties": false,
      "required": [
        "_seconds",
        "_nanoseconds"
      ],
      "properties": {
        "_seconds": {
          "type": "integer"
        },
        "_nanoseconds": {
          "type": "integer",
          "minimum": 0,
          "maximum": 999999999
        }
      }
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    }
  }
} as const;
