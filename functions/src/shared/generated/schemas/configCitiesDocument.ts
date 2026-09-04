/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const configCitiesDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/config_cities.schema.json",
  "title": "ConfigCitiesDocument",
  "description": "Public launch-market configuration stored at config/cities. The app picks from launched markets; canonical market ids disambiguate same-name cities globally.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "config_cities",
  "x-firestore-path": "config/cities",
  "x-document-id-field": "cities",
  "x-owner": "admin city configuration tooling",
  "required": [
    "version",
    "cityNames",
    "marketIds",
    "launchMarketIds",
    "cities",
    "markets"
  ],
  "definitions": {
    "launchStatus": {
      "type": "string",
      "enum": [
        "launched",
        "planned",
        "paused",
        "retired"
      ]
    },
    "cityPickerMarket": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "name",
        "cityId",
        "marketId",
        "slug",
        "label",
        "latitude",
        "longitude",
        "countryIsoCode",
        "currencyCode",
        "dialCode",
        "timeZone",
        "launchStatus",
        "profileSelectable",
        "hostCreatable",
        "eventCreatable",
        "exploreVisible"
      ],
      "properties": {
        "name": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120,
          "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$",
          "description": "App-facing selection id. Kept as name for existing CityData JSON, but stores the canonical market id."
        },
        "cityId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120,
          "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
        },
        "marketId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120,
          "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
        },
        "slug": {
          "type": "string",
          "minLength": 1,
          "maxLength": 80,
          "pattern": "^[a-z0-9-]+$"
        },
        "label": {
          "type": "string",
          "minLength": 1,
          "maxLength": 80
        },
        "latitude": {
          "type": "number",
          "minimum": -90,
          "maximum": 90
        },
        "longitude": {
          "type": "number",
          "minimum": -180,
          "maximum": 180
        },
        "countryIsoCode": {
          "type": "string",
          "pattern": "^[A-Z]{2}$"
        },
        "currencyCode": {
          "type": "string",
          "pattern": "^[A-Z]{3}$"
        },
        "dialCode": {
          "type": "string",
          "pattern": "^\\+\\d{1,4}$"
        },
        "timeZone": {
          "type": "string",
          "minLength": 1,
          "maxLength": 80
        },
        "launchStatus": {
          "type": "string",
          "enum": [
            "launched",
            "planned",
            "paused",
            "retired"
          ]
        },
        "profileSelectable": {
          "type": "boolean"
        },
        "hostCreatable": {
          "type": "boolean"
        },
        "eventCreatable": {
          "type": "boolean"
        },
        "exploreVisible": {
          "type": "boolean"
        }
      }
    },
    "canonicalMarket": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "marketId",
        "cityId",
        "slug",
        "label",
        "cityLabel",
        "regionCode",
        "regionName",
        "countryIsoCode",
        "countryName",
        "currencyCode",
        "dialCode",
        "timeZone",
        "latitude",
        "longitude",
        "aliases",
        "launchStatus",
        "profileSelectable",
        "hostCreatable",
        "eventCreatable",
        "exploreVisible"
      ],
      "properties": {
        "marketId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120,
          "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
        },
        "cityId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120,
          "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
        },
        "slug": {
          "type": "string",
          "minLength": 1,
          "maxLength": 80,
          "pattern": "^[a-z0-9-]+$"
        },
        "label": {
          "type": "string",
          "minLength": 1,
          "maxLength": 80
        },
        "cityLabel": {
          "type": "string",
          "minLength": 1,
          "maxLength": 80
        },
        "regionCode": {
          "type": "string",
          "minLength": 1,
          "maxLength": 16,
          "pattern": "^[A-Z0-9-]+$"
        },
        "regionName": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
        },
        "countryIsoCode": {
          "type": "string",
          "pattern": "^[A-Z]{2}$"
        },
        "countryName": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
        },
        "currencyCode": {
          "type": "string",
          "pattern": "^[A-Z]{3}$"
        },
        "dialCode": {
          "type": "string",
          "pattern": "^\\+\\d{1,4}$"
        },
        "timeZone": {
          "type": "string",
          "minLength": 1,
          "maxLength": 80
        },
        "latitude": {
          "type": "number",
          "minimum": -90,
          "maximum": 90
        },
        "longitude": {
          "type": "number",
          "minimum": -180,
          "maximum": 180
        },
        "aliases": {
          "type": "array",
          "maxItems": 40,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80,
            "pattern": "^[a-z0-9-]+$"
          }
        },
        "launchStatus": {
          "type": "string",
          "enum": [
            "launched",
            "planned",
            "paused",
            "retired"
          ]
        },
        "profileSelectable": {
          "type": "boolean"
        },
        "hostCreatable": {
          "type": "boolean"
        },
        "eventCreatable": {
          "type": "boolean"
        },
        "exploreVisible": {
          "type": "boolean"
        }
      }
    }
  },
  "properties": {
    "version": {
      "type": "integer",
      "minimum": 2
    },
    "cityNames": {
      "type": "array",
      "description": "Compatibility whitelist used by Firestore rules. Values are launched canonical market ids, not display city names.",
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 120,
        "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
      },
      "minItems": 1,
      "uniqueItems": true,
      "x-catch-ownership": "server-only"
    },
    "marketIds": {
      "type": "array",
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 120,
        "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
      },
      "minItems": 1,
      "uniqueItems": true,
      "x-catch-ownership": "server-only"
    },
    "launchMarketIds": {
      "type": "array",
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 120,
        "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
      },
      "minItems": 1,
      "uniqueItems": true,
      "x-catch-ownership": "server-only"
    },
    "cities": {
      "type": "array",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "name",
          "cityId",
          "marketId",
          "slug",
          "label",
          "latitude",
          "longitude",
          "countryIsoCode",
          "currencyCode",
          "dialCode",
          "timeZone",
          "launchStatus",
          "profileSelectable",
          "hostCreatable",
          "eventCreatable",
          "exploreVisible"
        ],
        "properties": {
          "name": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120,
            "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$",
            "description": "App-facing selection id. Kept as name for existing CityData JSON, but stores the canonical market id."
          },
          "cityId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120,
            "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
          },
          "marketId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120,
            "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
          },
          "slug": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80,
            "pattern": "^[a-z0-9-]+$"
          },
          "label": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "latitude": {
            "type": "number",
            "minimum": -90,
            "maximum": 90
          },
          "longitude": {
            "type": "number",
            "minimum": -180,
            "maximum": 180
          },
          "countryIsoCode": {
            "type": "string",
            "pattern": "^[A-Z]{2}$"
          },
          "currencyCode": {
            "type": "string",
            "pattern": "^[A-Z]{3}$"
          },
          "dialCode": {
            "type": "string",
            "pattern": "^\\+\\d{1,4}$"
          },
          "timeZone": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "launchStatus": {
            "type": "string",
            "enum": [
              "launched",
              "planned",
              "paused",
              "retired"
            ]
          },
          "profileSelectable": {
            "type": "boolean"
          },
          "hostCreatable": {
            "type": "boolean"
          },
          "eventCreatable": {
            "type": "boolean"
          },
          "exploreVisible": {
            "type": "boolean"
          }
        }
      },
      "uniqueItems": true,
      "x-catch-ownership": "server-only"
    },
    "markets": {
      "type": "array",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "marketId",
          "cityId",
          "slug",
          "label",
          "cityLabel",
          "regionCode",
          "regionName",
          "countryIsoCode",
          "countryName",
          "currencyCode",
          "dialCode",
          "timeZone",
          "latitude",
          "longitude",
          "aliases",
          "launchStatus",
          "profileSelectable",
          "hostCreatable",
          "eventCreatable",
          "exploreVisible"
        ],
        "properties": {
          "marketId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120,
            "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
          },
          "cityId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120,
            "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
          },
          "slug": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80,
            "pattern": "^[a-z0-9-]+$"
          },
          "label": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "cityLabel": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "regionCode": {
            "type": "string",
            "minLength": 1,
            "maxLength": 16,
            "pattern": "^[A-Z0-9-]+$"
          },
          "regionName": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120
          },
          "countryIsoCode": {
            "type": "string",
            "pattern": "^[A-Z]{2}$"
          },
          "countryName": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120
          },
          "currencyCode": {
            "type": "string",
            "pattern": "^[A-Z]{3}$"
          },
          "dialCode": {
            "type": "string",
            "pattern": "^\\+\\d{1,4}$"
          },
          "timeZone": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "latitude": {
            "type": "number",
            "minimum": -90,
            "maximum": 90
          },
          "longitude": {
            "type": "number",
            "minimum": -180,
            "maximum": 180
          },
          "aliases": {
            "type": "array",
            "maxItems": 40,
            "uniqueItems": true,
            "items": {
              "type": "string",
              "minLength": 1,
              "maxLength": 80,
              "pattern": "^[a-z0-9-]+$"
            }
          },
          "launchStatus": {
            "type": "string",
            "enum": [
              "launched",
              "planned",
              "paused",
              "retired"
            ]
          },
          "profileSelectable": {
            "type": "boolean"
          },
          "hostCreatable": {
            "type": "boolean"
          },
          "eventCreatable": {
            "type": "boolean"
          },
          "exploreVisible": {
            "type": "boolean"
          }
        }
      },
      "minItems": 1,
      "uniqueItems": true,
      "x-catch-ownership": "server-only"
    }
  }
} as const;
