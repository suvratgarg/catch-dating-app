/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/generate_schema_contracts.mjs

/**
 * Callable payload accepted by createClub.
 */
export interface CreateClubCallablePayload {
  clubId?: string;
  name: string;
  description: string;
  location: string | null;
  area: string;
  imageUrl?: string | null;
  instagramHandle?: string | null;
  phoneNumber?: string | null;
  email?: string | null;
}
