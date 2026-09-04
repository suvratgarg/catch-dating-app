/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const createRazorpayHostPaymentAccountCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/create_razorpay_host_payment_account_payload.schema.json",
  "title": "CreateRazorpayHostPaymentAccountCallablePayload",
  "description": "Creates or continues an India host's Razorpay Route linked-account setup. Legal, stakeholder, and settlement details are sent to Razorpay and are never persisted in Catch Firestore.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "legalBusinessName",
    "businessType",
    "contactName",
    "email",
    "phone",
    "businessModel",
    "businessPan",
    "bankAccountNumber",
    "ifscCode",
    "beneficiaryName",
    "stakeholderName",
    "stakeholderEmail",
    "stakeholderPhone",
    "stakeholderPan",
    "stakeholderOwnershipPercent",
    "stakeholderIsDirector",
    "stakeholderIsExecutive",
    "termsAccepted"
  ],
  "properties": {
    "legalBusinessName": {
      "type": "string",
      "minLength": 4,
      "maxLength": 200
    },
    "businessType": {
      "type": "string",
      "enum": [
        "individual",
        "proprietorship",
        "partnership",
        "private_limited",
        "public_limited",
        "llp",
        "trust",
        "society",
        "ngo"
      ]
    },
    "contactName": {
      "type": "string",
      "minLength": 4,
      "maxLength": 255
    },
    "email": {
      "type": "string",
      "format": "email",
      "maxLength": 132
    },
    "phone": {
      "type": "string",
      "pattern": "^[+]?[0-9]{8,15}$"
    },
    "businessModel": {
      "type": "string",
      "minLength": 1,
      "maxLength": 255
    },
    "businessPan": {
      "type": "string",
      "pattern": "^[A-Z]{5}[0-9]{4}[A-Z]$"
    },
    "bankAccountNumber": {
      "type": "string",
      "pattern": "^[0-9]{5,20}$"
    },
    "ifscCode": {
      "type": "string",
      "pattern": "^[A-Z]{4}0[A-Z0-9]{6}$"
    },
    "beneficiaryName": {
      "type": "string",
      "minLength": 2,
      "maxLength": 120
    },
    "stakeholderName": {
      "type": "string",
      "minLength": 2,
      "maxLength": 255
    },
    "stakeholderEmail": {
      "type": "string",
      "format": "email",
      "maxLength": 132
    },
    "stakeholderPhone": {
      "type": "string",
      "pattern": "^[+]?[0-9]{8,15}$"
    },
    "stakeholderPan": {
      "type": "string",
      "pattern": "^[A-Z]{5}[0-9]{4}[A-Z]$"
    },
    "stakeholderOwnershipPercent": {
      "type": "number",
      "minimum": 0,
      "maximum": 100
    },
    "stakeholderIsDirector": {
      "type": "boolean"
    },
    "stakeholderIsExecutive": {
      "type": "boolean"
    },
    "termsAccepted": {
      "type": "boolean",
      "const": true
    }
  }
} as const;
