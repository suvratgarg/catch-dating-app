/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerFormTemplateCatalog = {
  "schemaVersion": 1,
  "kind": "organizerFormTemplates",
  "templates": [
    {
      "id": "event-application",
      "version": 1,
      "title": "Event application",
      "description": "Review interest and fit before confirming a place.",
      "purpose": "application",
      "identityPolicy": "phoneVerified",
      "sections": [
        {
          "id": "about-you",
          "title": "About you",
          "description": "Basic contact information for this application.",
          "questions": [
            {
              "key": "displayName",
              "label": "Full name",
              "helpText": null,
              "kind": "shortText",
              "required": true,
              "canonicalFieldId": "displayName",
              "privacyClass": "contact"
            },
            {
              "key": "phoneNumber",
              "label": "Phone number",
              "helpText": "Used only for this application and approved follow-up.",
              "kind": "phone",
              "required": true,
              "canonicalFieldId": "phoneNumber",
              "privacyClass": "contact"
            },
            {
              "key": "motivation",
              "label": "Why would you like to join?",
              "helpText": null,
              "kind": "longText",
              "required": true,
              "canonicalFieldId": null,
              "privacyClass": "organizerCustom"
            }
          ]
        }
      ]
    },
    {
      "id": "event-registration",
      "version": 1,
      "title": "Event registration",
      "description": "Collect the information needed to request a place.",
      "purpose": "registration",
      "identityPolicy": "emailOrPhoneVerified",
      "sections": [
        {
          "id": "registration",
          "title": "Registration",
          "description": null,
          "questions": [
            {
              "key": "displayName",
              "label": "Full name",
              "helpText": null,
              "kind": "shortText",
              "required": true,
              "canonicalFieldId": "displayName",
              "privacyClass": "contact"
            },
            {
              "key": "email",
              "label": "Email",
              "helpText": null,
              "kind": "email",
              "required": true,
              "canonicalFieldId": "email",
              "privacyClass": "contact"
            },
            {
              "key": "accessibility",
              "label": "Is there anything we should know to make the event accessible?",
              "helpText": null,
              "kind": "longText",
              "required": false,
              "canonicalFieldId": null,
              "privacyClass": "sensitive"
            }
          ]
        }
      ]
    },
    {
      "id": "dinner-guest-intake",
      "version": 1,
      "title": "Dinner guest intake",
      "description": "Dietary, seating, and accessibility details for a hosted meal.",
      "purpose": "intake",
      "identityPolicy": "emailOrPhoneVerified",
      "sections": [
        {
          "id": "guest-details",
          "title": "Guest details",
          "description": "Help us prepare your place at the table.",
          "questions": [
            {
              "key": "displayName",
              "label": "Full name",
              "helpText": null,
              "kind": "shortText",
              "required": true,
              "canonicalFieldId": "displayName",
              "privacyClass": "contact"
            },
            {
              "key": "dietaryRequirements",
              "label": "Dietary requirements",
              "helpText": "Include allergies and ingredients you cannot eat.",
              "kind": "longText",
              "required": false,
              "canonicalFieldId": null,
              "privacyClass": "sensitive"
            },
            {
              "key": "seatingNotes",
              "label": "Seating or accessibility notes",
              "helpText": null,
              "kind": "longText",
              "required": false,
              "canonicalFieldId": null,
              "privacyClass": "sensitive"
            }
          ]
        }
      ]
    },
    {
      "id": "run-walk-participation",
      "version": 1,
      "title": "Run or walk participation",
      "description": "Pace, distance, route, and accessibility information for moving groups.",
      "purpose": "intake",
      "identityPolicy": "phoneVerified",
      "sections": [
        {
          "id": "pace-and-route",
          "title": "Pace and route",
          "description": "Used to place people in a suitable pace pod.",
          "questions": [
            {
              "key": "displayName",
              "label": "Full name",
              "helpText": null,
              "kind": "shortText",
              "required": true,
              "canonicalFieldId": "displayName",
              "privacyClass": "contact"
            },
            {
              "key": "pace",
              "label": "Comfortable pace",
              "helpText": "Use min/km, min/mile, or describe your walking pace.",
              "kind": "shortText",
              "required": true,
              "canonicalFieldId": null,
              "privacyClass": "organizerCustom"
            },
            {
              "key": "distance",
              "label": "Preferred distance",
              "helpText": null,
              "kind": "shortText",
              "required": false,
              "canonicalFieldId": null,
              "privacyClass": "organizerCustom"
            },
            {
              "key": "routeAccess",
              "label": "Route or accessibility needs",
              "helpText": null,
              "kind": "longText",
              "required": false,
              "canonicalFieldId": null,
              "privacyClass": "sensitive"
            }
          ]
        }
      ]
    },
    {
      "id": "racket-session",
      "version": 1,
      "title": "Racket-sport session",
      "description": "Collect level and pairing inputs for pickleball, padel, tennis, or badminton.",
      "purpose": "intake",
      "identityPolicy": "phoneVerified",
      "sections": [
        {
          "id": "playing-profile",
          "title": "Playing profile",
          "description": "Used only to organize this session.",
          "questions": [
            {
              "key": "displayName",
              "label": "Full name",
              "helpText": null,
              "kind": "shortText",
              "required": true,
              "canonicalFieldId": "displayName",
              "privacyClass": "contact"
            },
            {
              "key": "level",
              "label": "Playing level",
              "helpText": "Beginner, improving, intermediate, advanced, or your rating.",
              "kind": "shortText",
              "required": true,
              "canonicalFieldId": null,
              "privacyClass": "organizerCustom"
            },
            {
              "key": "preferredSide",
              "label": "Preferred side or position",
              "helpText": null,
              "kind": "shortText",
              "required": false,
              "canonicalFieldId": null,
              "privacyClass": "organizerCustom"
            },
            {
              "key": "partnerRequest",
              "label": "Partner or pairing request",
              "helpText": null,
              "kind": "shortText",
              "required": false,
              "canonicalFieldId": null,
              "privacyClass": "organizerCustom"
            }
          ]
        }
      ]
    },
    {
      "id": "quiz-team-night",
      "version": 1,
      "title": "Quiz or team night",
      "description": "Register teams, tables, and accessibility needs.",
      "purpose": "registration",
      "identityPolicy": "emailOrPhoneVerified",
      "sections": [
        {
          "id": "team-details",
          "title": "Team details",
          "description": null,
          "questions": [
            {
              "key": "displayName",
              "label": "Your name",
              "helpText": null,
              "kind": "shortText",
              "required": true,
              "canonicalFieldId": "displayName",
              "privacyClass": "contact"
            },
            {
              "key": "teamName",
              "label": "Team name",
              "helpText": "Leave blank if you would like us to place you.",
              "kind": "shortText",
              "required": false,
              "canonicalFieldId": null,
              "privacyClass": "organizerCustom"
            },
            {
              "key": "teamSize",
              "label": "Number of people",
              "helpText": null,
              "kind": "number",
              "required": true,
              "canonicalFieldId": null,
              "privacyClass": "organizerCustom"
            },
            {
              "key": "accessibility",
              "label": "Accessibility needs",
              "helpText": null,
              "kind": "longText",
              "required": false,
              "canonicalFieldId": null,
              "privacyClass": "sensitive"
            }
          ]
        }
      ]
    },
    {
      "id": "event-waiver",
      "version": 1,
      "title": "Event waiver",
      "description": "Capture versioned acknowledgements and a signature.",
      "purpose": "waiver",
      "identityPolicy": "phoneVerified",
      "sections": [
        {
          "id": "waiver",
          "title": "Waiver",
          "description": "Replace the example text with reviewed terms before publishing.",
          "questions": [
            {
              "key": "displayName",
              "label": "Full legal name",
              "helpText": null,
              "kind": "shortText",
              "required": true,
              "canonicalFieldId": "displayName",
              "privacyClass": "contact"
            },
            {
              "key": "termsAcknowledgement",
              "label": "I have read and accept the event terms",
              "helpText": null,
              "kind": "acknowledgement",
              "required": true,
              "canonicalFieldId": null,
              "privacyClass": "organizerCustom"
            },
            {
              "key": "signature",
              "label": "Signature",
              "helpText": null,
              "kind": "signature",
              "required": true,
              "canonicalFieldId": null,
              "privacyClass": "sensitive"
            }
          ]
        }
      ]
    },
    {
      "id": "post-event-feedback",
      "version": 1,
      "title": "Post-event feedback",
      "description": "Measure the experience and provide a private safety channel.",
      "purpose": "feedback",
      "identityPolicy": "anonymous",
      "sections": [
        {
          "id": "your-feedback",
          "title": "Your feedback",
          "description": "Anonymous unless you choose to identify yourself in an answer.",
          "questions": [
            {
              "key": "rating",
              "label": "How would you rate the event?",
              "helpText": "Use a number from 1 to 5.",
              "kind": "number",
              "required": true,
              "canonicalFieldId": null,
              "privacyClass": "organizerCustom"
            },
            {
              "key": "workedWell",
              "label": "What worked well?",
              "helpText": null,
              "kind": "longText",
              "required": false,
              "canonicalFieldId": null,
              "privacyClass": "organizerCustom"
            },
            {
              "key": "privateNote",
              "label": "Private note for the organizer",
              "helpText": null,
              "kind": "longText",
              "required": false,
              "canonicalFieldId": null,
              "privacyClass": "sensitive"
            },
            {
              "key": "safetyConcern",
              "label": "Do you need a safety follow-up?",
              "helpText": "This should not be used for emergencies.",
              "kind": "boolean",
              "required": false,
              "canonicalFieldId": null,
              "privacyClass": "sensitive"
            }
          ]
        }
      ]
    },
    {
      "id": "blank",
      "version": 1,
      "title": "Blank form",
      "description": "Start with one empty section and add your own questions.",
      "purpose": "survey",
      "identityPolicy": "anonymous",
      "sections": [
        {
          "id": "first-section",
          "title": "First section",
          "description": null,
          "questions": []
        }
      ]
    }
  ]
} as const;
