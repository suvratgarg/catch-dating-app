/// Returns the canonical review document ID for one user's review of a club.
///
/// Keeping this deterministic guarantees a single review document per
/// `(runClubId, reviewerUserId)` pair.
String reviewDocumentId({
  required String runClubId,
  required String reviewerUserId,
}) => 'club_${runClubId}_user_$reviewerUserId';
