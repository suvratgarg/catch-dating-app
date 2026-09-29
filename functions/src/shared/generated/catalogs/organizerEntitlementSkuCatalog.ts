/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerEntitlementSkuCatalog = {
  "catalogVersion": 1,
  "kind": "organizerEntitlementSkus",
  "skus": {
    "wedding_essentials": {
      "label": "Wedding Essentials",
      "unit": "program",
      "priceMinor": 2499900,
      "currency": "INR",
      "limits": {
        "guests": 150,
        "functions": 5,
        "staffAssignments": 10,
        "momentsPerFunction": 3
      },
      "capabilitiesAllowed": [
        "forms",
        "messaging"
      ],
      "includedFlightDays": 0,
      "includedWaConversations": 0,
      "stakeholderSeats": 2
    },
    "wedding_pro": {
      "label": "Wedding Pro",
      "unit": "program",
      "priceMinor": 5999900,
      "currency": "INR",
      "limits": {
        "guests": 400,
        "functions": 10,
        "staffAssignments": 30,
        "momentsPerFunction": null
      },
      "capabilitiesAllowed": [
        "arrivalsTransport",
        "accommodation",
        "forms",
        "messaging"
      ],
      "includedFlightDays": 0,
      "includedWaConversations": 0,
      "stakeholderSeats": 6
    },
    "wedding_signature": {
      "label": "Wedding Signature",
      "unit": "program",
      "priceMinor": 14999900,
      "currency": "INR",
      "limits": {
        "guests": 1000,
        "functions": null,
        "staffAssignments": 100,
        "momentsPerFunction": null
      },
      "capabilitiesAllowed": [
        "arrivalsTransport",
        "accommodation",
        "forms",
        "messaging"
      ],
      "includedFlightDays": 300,
      "includedWaConversations": 3000,
      "stakeholderSeats": null
    },
    "wedding_transport_addon": {
      "label": "Arrivals desk + dispatch add-on",
      "unit": "program",
      "priceMinor": 1499900,
      "currency": "INR",
      "limits": {
        "guests": null,
        "functions": null,
        "staffAssignments": null,
        "momentsPerFunction": null
      },
      "capabilitiesAllowed": [
        "arrivalsTransport"
      ],
      "includedFlightDays": 0,
      "includedWaConversations": 0,
      "stakeholderSeats": null
    },
    "planner_annual": {
      "label": "Planner annual (quote)",
      "unit": "organizerYear",
      "priceMinor": null,
      "currency": "INR",
      "limits": {
        "guests": null,
        "functions": null,
        "staffAssignments": null,
        "momentsPerFunction": null
      },
      "capabilitiesAllowed": [
        "arrivalsTransport",
        "accommodation",
        "forms",
        "messaging"
      ],
      "includedFlightDays": 0,
      "includedWaConversations": 0,
      "stakeholderSeats": null
    }
  }
} as const;
