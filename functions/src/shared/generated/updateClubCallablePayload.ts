/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/generate_schema_contracts.mjs

/**
 * Callable payload accepted by updateClub.
 */
export interface UpdateClubCallablePayload {
  clubId: string;
  fields: {
    name?: string;
    description?: string;
    location?: string | null;
    area?: string;
    hostName?: string;
    hostAvatarUrl?: string | null;
    imageUrl?: string | null;
    /**
     * @maxItems 12
     */
    tags?: string[];
    instagramHandle?: string | null;
    phoneNumber?: string | null;
    email?: string | null;
  };
}
