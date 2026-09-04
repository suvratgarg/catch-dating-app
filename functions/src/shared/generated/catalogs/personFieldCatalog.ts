/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const personFieldCatalog = {
  "schemaVersion": 1,
  "kind": "personFields",
  "organizerAccessPolicy": "submittedQuestionGrantOnly",
  "publicProfileMetadataPolicy": "structuralMappingOnlyNotAuthorization",
  "tabularChoiceImportPolicy": "preserveAsTextUntilOptionsMapped",
  "authenticationPolicy": "identityVerificationDoesNotGrantDataAccess",
  "applicationReviewPolicy": "reviewEveryQuestionBeforeEachSubmission",
  "hostCommercePolicy": "eventScopedAggregatesOnly",
  "eventStaffPolicy": "eventScopedRosterAndAttendanceOnly",
  "employeeAccessPolicy": "purposeScopedRoleGatedMaskedAndAudited",
  "rawPiiPolicy": "breakGlassOnly",
  "fields": [
    {
      "id": "givenName",
      "aliases": [
        "firstname",
        "givenname"
      ],
      "questionKind": "shortText",
      "transform": "trim",
      "privacyClass": "contact",
      "prefillPolicy": "participantReviewRequired",
      "hostPresentation": "sortable",
      "authority": "privateProfile",
      "privateProfilePath": "firstName",
      "derivedFrom": null,
      "publicProfileProjection": "never",
      "publicProfilePath": null
    },
    {
      "id": "familyName",
      "aliases": [
        "familyname",
        "lastname",
        "surname"
      ],
      "questionKind": "shortText",
      "transform": "trim",
      "privacyClass": "contact",
      "prefillPolicy": "participantReviewRequired",
      "hostPresentation": "sortable",
      "authority": "privateProfile",
      "privateProfilePath": "lastName",
      "derivedFrom": null,
      "publicProfileProjection": "never",
      "publicProfilePath": null
    },
    {
      "id": "displayName",
      "aliases": [
        "displayname",
        "name",
        "fullname",
        "yourname",
        "yourfullname"
      ],
      "questionKind": "shortText",
      "transform": "trim",
      "privacyClass": "contact",
      "prefillPolicy": "participantReviewRequired",
      "hostPresentation": "sortable",
      "authority": "privateProfile",
      "privateProfilePath": "displayName",
      "derivedFrom": null,
      "publicProfileProjection": "direct",
      "publicProfilePath": "name"
    },
    {
      "id": "dateOfBirth",
      "aliases": [
        "dob",
        "dateofbirth",
        "birthdate"
      ],
      "questionKind": "date",
      "transform": "isoDate",
      "privacyClass": "sensitive",
      "prefillPolicy": "participantReviewRequired",
      "hostPresentation": "sortable",
      "authority": "privateProfile",
      "privateProfilePath": "dateOfBirth",
      "derivedFrom": null,
      "publicProfileProjection": "derived",
      "publicProfilePath": "age"
    },
    {
      "id": "age",
      "aliases": [
        "age"
      ],
      "questionKind": "number",
      "transform": "number",
      "privacyClass": "sensitive",
      "prefillPolicy": "participantReviewRequired",
      "hostPresentation": "sortable",
      "authority": "derived",
      "privateProfilePath": null,
      "derivedFrom": "dateOfBirth",
      "publicProfileProjection": "derived",
      "publicProfilePath": "age"
    },
    {
      "id": "gender",
      "aliases": [
        "gender"
      ],
      "questionKind": "singleChoice",
      "transform": "trim",
      "privacyClass": "sensitive",
      "prefillPolicy": "participantReviewRequired",
      "hostPresentation": "filterable",
      "authority": "privateProfile",
      "privateProfilePath": "gender",
      "derivedFrom": null,
      "publicProfileProjection": "direct",
      "publicProfilePath": "gender"
    },
    {
      "id": "phoneNumber",
      "aliases": [
        "phone",
        "phonenumber",
        "mobile",
        "mobilenumber",
        "whatsapp",
        "whatsappnumber"
      ],
      "questionKind": "phone",
      "transform": "e164",
      "privacyClass": "contact",
      "prefillPolicy": "participantReviewRequired",
      "hostPresentation": "detailOnly",
      "authority": "firebaseAuth",
      "privateProfilePath": "phoneNumber",
      "derivedFrom": null,
      "publicProfileProjection": "never",
      "publicProfilePath": null
    },
    {
      "id": "email",
      "aliases": [
        "email",
        "emailaddress"
      ],
      "questionKind": "email",
      "transform": "trim",
      "privacyClass": "contact",
      "prefillPolicy": "participantReviewRequired",
      "hostPresentation": "detailOnly",
      "authority": "privateProfile",
      "privateProfilePath": "email",
      "derivedFrom": null,
      "publicProfileProjection": "never",
      "publicProfilePath": null
    },
    {
      "id": "instagramHandle",
      "aliases": [
        "instagram",
        "instagramhandle",
        "instagramprofile"
      ],
      "questionKind": "shortText",
      "transform": "trim",
      "privacyClass": "profile",
      "prefillPolicy": "participantReviewRequired",
      "hostPresentation": "detailOnly",
      "authority": "privateProfile",
      "privateProfilePath": "instagramHandle",
      "derivedFrom": null,
      "publicProfileProjection": "never",
      "publicProfilePath": null
    },
    {
      "id": "linkedinUrl",
      "aliases": [
        "linkedin",
        "linkedinurl",
        "linkedinprofile"
      ],
      "questionKind": "url",
      "transform": "assetUrl",
      "privacyClass": "profile",
      "prefillPolicy": "participantReviewRequired",
      "hostPresentation": "detailOnly",
      "authority": "intakeProfile",
      "privateProfilePath": null,
      "derivedFrom": null,
      "publicProfileProjection": "never",
      "publicProfilePath": null
    },
    {
      "id": "profilePhoto",
      "aliases": [
        "photo",
        "profilephoto",
        "uploadaphoto"
      ],
      "questionKind": "file",
      "transform": "assetUrl",
      "privacyClass": "profile",
      "prefillPolicy": "participantReviewRequired",
      "hostPresentation": "detailOnly",
      "authority": "privateProfile",
      "privateProfilePath": "profilePhotos",
      "derivedFrom": null,
      "publicProfileProjection": "direct",
      "publicProfilePath": "profilePhotos"
    },
    {
      "id": "city",
      "aliases": [
        "city",
        "location"
      ],
      "questionKind": "shortText",
      "transform": "trim",
      "privacyClass": "profile",
      "prefillPolicy": "participantReviewRequired",
      "hostPresentation": "filterable",
      "authority": "privateProfile",
      "privateProfilePath": "city",
      "derivedFrom": null,
      "publicProfileProjection": "direct",
      "publicProfilePath": "city"
    },
    {
      "id": "heightCm",
      "aliases": [
        "height",
        "heightcm"
      ],
      "questionKind": "number",
      "transform": "number",
      "privacyClass": "profile",
      "prefillPolicy": "participantReviewRequired",
      "hostPresentation": "sortable",
      "authority": "privateProfile",
      "privateProfilePath": "height",
      "derivedFrom": null,
      "publicProfileProjection": "direct",
      "publicProfilePath": "height"
    },
    {
      "id": "occupation",
      "aliases": [
        "occupation",
        "job",
        "profession"
      ],
      "questionKind": "shortText",
      "transform": "trim",
      "privacyClass": "profile",
      "prefillPolicy": "participantReviewRequired",
      "hostPresentation": "filterable",
      "authority": "privateProfile",
      "privateProfilePath": "occupation",
      "derivedFrom": null,
      "publicProfileProjection": "direct",
      "publicProfilePath": "occupation"
    },
    {
      "id": "company",
      "aliases": [
        "company",
        "workplace",
        "employer"
      ],
      "questionKind": "shortText",
      "transform": "trim",
      "privacyClass": "profile",
      "prefillPolicy": "participantReviewRequired",
      "hostPresentation": "filterable",
      "authority": "privateProfile",
      "privateProfilePath": "company",
      "derivedFrom": null,
      "publicProfileProjection": "direct",
      "publicProfilePath": "company"
    },
    {
      "id": "education",
      "aliases": [
        "education",
        "educationlevel"
      ],
      "questionKind": "singleChoice",
      "transform": "trim",
      "privacyClass": "profile",
      "prefillPolicy": "participantReviewRequired",
      "hostPresentation": "filterable",
      "authority": "privateProfile",
      "privateProfilePath": "education",
      "derivedFrom": null,
      "publicProfileProjection": "direct",
      "publicProfilePath": "education"
    },
    {
      "id": "languages",
      "aliases": [
        "language",
        "languages",
        "languagesspoken"
      ],
      "questionKind": "multiChoice",
      "transform": "splitOptions",
      "privacyClass": "profile",
      "prefillPolicy": "participantReviewRequired",
      "hostPresentation": "filterable",
      "authority": "privateProfile",
      "privateProfilePath": "languages",
      "derivedFrom": null,
      "publicProfileProjection": "direct",
      "publicProfilePath": "languages"
    },
    {
      "id": "relationshipGoal",
      "aliases": [
        "lookingfor",
        "whatareyoulookingfor",
        "relationshipgoal"
      ],
      "questionKind": "singleChoice",
      "transform": "trim",
      "privacyClass": "sensitive",
      "prefillPolicy": "participantReviewRequired",
      "hostPresentation": "filterable",
      "authority": "privateProfile",
      "privateProfilePath": "relationshipGoal",
      "derivedFrom": null,
      "publicProfileProjection": "direct",
      "publicProfilePath": "relationshipGoal"
    },
    {
      "id": "interestedInGenders",
      "aliases": [
        "interestedin",
        "interestedingenders",
        "genderpreference"
      ],
      "questionKind": "multiChoice",
      "transform": "splitOptions",
      "privacyClass": "sensitive",
      "prefillPolicy": "participantReviewRequired",
      "hostPresentation": "filterable",
      "authority": "privateProfile",
      "privateProfilePath": "interestedInGenders",
      "derivedFrom": null,
      "publicProfileProjection": "never",
      "publicProfilePath": null
    },
    {
      "id": "drinking",
      "aliases": [
        "drinking",
        "drinkinghabit"
      ],
      "questionKind": "singleChoice",
      "transform": "trim",
      "privacyClass": "sensitive",
      "prefillPolicy": "participantReviewRequired",
      "hostPresentation": "filterable",
      "authority": "privateProfile",
      "privateProfilePath": "drinking",
      "derivedFrom": null,
      "publicProfileProjection": "direct",
      "publicProfilePath": "drinking"
    },
    {
      "id": "smoking",
      "aliases": [
        "smoking",
        "smokinghabit"
      ],
      "questionKind": "singleChoice",
      "transform": "trim",
      "privacyClass": "sensitive",
      "prefillPolicy": "participantReviewRequired",
      "hostPresentation": "filterable",
      "authority": "privateProfile",
      "privateProfilePath": "smoking",
      "derivedFrom": null,
      "publicProfileProjection": "direct",
      "publicProfilePath": "smoking"
    },
    {
      "id": "religion",
      "aliases": [
        "religion",
        "faith"
      ],
      "questionKind": "singleChoice",
      "transform": "trim",
      "privacyClass": "sensitive",
      "prefillPolicy": "participantReviewRequired",
      "hostPresentation": "filterable",
      "authority": "privateProfile",
      "privateProfilePath": "religion",
      "derivedFrom": null,
      "publicProfileProjection": "direct",
      "publicProfilePath": "religion"
    },
    {
      "id": "workout",
      "aliases": [
        "workout",
        "exercise",
        "workoutfrequency"
      ],
      "questionKind": "singleChoice",
      "transform": "trim",
      "privacyClass": "profile",
      "prefillPolicy": "participantReviewRequired",
      "hostPresentation": "filterable",
      "authority": "privateProfile",
      "privateProfilePath": "workout",
      "derivedFrom": null,
      "publicProfileProjection": "direct",
      "publicProfilePath": "workout"
    },
    {
      "id": "diet",
      "aliases": [
        "diet",
        "dietarypreference"
      ],
      "questionKind": "singleChoice",
      "transform": "trim",
      "privacyClass": "profile",
      "prefillPolicy": "participantReviewRequired",
      "hostPresentation": "filterable",
      "authority": "privateProfile",
      "privateProfilePath": "diet",
      "derivedFrom": null,
      "publicProfileProjection": "direct",
      "publicProfilePath": "diet"
    },
    {
      "id": "children",
      "aliases": [
        "children",
        "kids",
        "childrenstatus"
      ],
      "questionKind": "singleChoice",
      "transform": "trim",
      "privacyClass": "sensitive",
      "prefillPolicy": "participantReviewRequired",
      "hostPresentation": "filterable",
      "authority": "privateProfile",
      "privateProfilePath": "children",
      "derivedFrom": null,
      "publicProfileProjection": "direct",
      "publicProfilePath": "children"
    }
  ]
} as const;
