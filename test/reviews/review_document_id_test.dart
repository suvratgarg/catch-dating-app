import 'package:catch_dating_app/reviews/domain/review_document_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reviewDocumentId is deterministic per club and reviewer', () {
    expect(
      reviewDocumentId(
        runClubId: 'club-123',
        reviewerUserId: 'user-456',
      ),
      'club_club-123_user_user-456',
    );
  });
}
