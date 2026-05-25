/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable response returned by listSuvbotDemoActions. Each action describes a button in the Suvbot demo-operations menu.
 */
export interface ListSuvbotDemoActionsCallableResponse {
  actions: {
    id: string;
    label: string;
    description: string;
    icon: string;
    destructive?: boolean;
    requiresText?: boolean;
  }[];
}
