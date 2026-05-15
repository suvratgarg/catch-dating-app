/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/generate_schema_contracts.mjs

/**
 * Client-owned Firestore update operation for notifications/{uid}/items/{notificationId}.
 */
export interface MarkNotificationReadClientWrite {
  path: {
    uid: string;
    notificationId: string;
  };
  data: {
    /**
     * Serialized Firestore Timestamp fixture shape.
     */
    readAt: {
      _seconds: number;
      _nanoseconds: number;
    };
  };
}
