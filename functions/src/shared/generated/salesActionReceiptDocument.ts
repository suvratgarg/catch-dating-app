/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Actor- and scope-bound immutable idempotency receipt; result is bounded and never public.
 */
export interface SalesActionReceiptDocument {
  schemaVersion: 1;
  classification: "sales_private";
  requestId: string;
  requestHash: string;
  action:
    | "hosts.create"
    | "hosts.update"
    | "tasks.upsert"
    | "opportunities.upsert"
    | "activities.log"
    | "fields.create"
    | "fields.setValue"
    | "intents.link"
    | "imports.apply"
    | "contacts.upsert"
    | "evidence.add"
    | "accounts.setSuppression"
    | "contacts.setContactability"
    | "evidence.propose"
    | "evidence.reviewProposal"
    | "commercial.pilots.upsert"
    | "commercial.quotes.revise"
    | "commercial.quotes.approve"
    | "commercial.quotes.accept"
    | "commercial.finance.attest"
    | "imports.compensation.apply"
    | "imports.history.apply";
  actorUid: string;
  clientId: string | null;
  clientAuthUid: string | null;
  delegationId: string | null;
  organizerId: string | null;
  createdAt: string;
  result: {
    [k: string]:
      | (
          | (
              | (string | number | boolean | null)
              | (string | number | boolean | null)[]
              | {
                  [k: string]: string | number | boolean | null;
                }
            )
          | (
              | (string | number | boolean | null)
              | (string | number | boolean | null)[]
              | {
                  [k: string]: string | number | boolean | null;
                }
            )[]
          | {
              [k: string]:
                | (string | number | boolean | null)
                | (string | number | boolean | null)[]
                | {
                    [k: string]: string | number | boolean | null;
                  };
            }
        )
      | (
          | (
              | (string | number | boolean | null)
              | (string | number | boolean | null)[]
              | {
                  [k: string]: string | number | boolean | null;
                }
            )
          | (
              | (string | number | boolean | null)
              | (string | number | boolean | null)[]
              | {
                  [k: string]: string | number | boolean | null;
                }
            )[]
          | {
              [k: string]:
                | (string | number | boolean | null)
                | (string | number | boolean | null)[]
                | {
                    [k: string]: string | number | boolean | null;
                  };
            }
        )[]
      | {
          [k: string]:
            | (
                | (string | number | boolean | null)
                | (string | number | boolean | null)[]
                | {
                    [k: string]: string | number | boolean | null;
                  }
              )
            | (
                | (string | number | boolean | null)
                | (string | number | boolean | null)[]
                | {
                    [k: string]: string | number | boolean | null;
                  }
              )[]
            | {
                [k: string]:
                  | (string | number | boolean | null)
                  | (string | number | boolean | null)[]
                  | {
                      [k: string]: string | number | boolean | null;
                    };
              };
        };
  };
}
