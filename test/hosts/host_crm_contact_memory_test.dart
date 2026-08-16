import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('contact detail parses manual tags, notes, and campaign sends', () {
    final detail = HostAudienceContactDetail.fromCallableData({
      'organizerId': 'organizer-1',
      'contactId': 'contact-1',
      'displayName': 'Ananya Rao',
      'sourceDisplayName': 'Ananya Rao',
      'displayNameOverride': null,
      'phoneE164': null,
      'email': null,
      'linkedAccount': true,
      'identityState': 'verified',
      'identityConfidence': 'verified',
      'ambiguousCandidateContactIds': <Object?>[],
      'whatsappAdminSuppressed': false,
      'traits': {
        'expectedEventCount': 1,
        'attendedEventCount': 1,
        'cancelledEventCount': 0,
        'noShowCount': 0,
        'importedEventCount': 0,
        'attendanceRate': 1,
        'segmentIds': <Object?>['regular'],
        'sourceCoverage': 'exact',
      },
      'revenue': {'coverage': 'exact', 'amounts': <Object?>[]},
      'events': <Object?>[],
      'eventsTruncated': false,
      'manualTags': <Object?>[
        {
          'tagId': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
          'label': 'Brings friends',
        },
      ],
      'manualTagVocabulary': <Object?>[
        {
          'tagId': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
          'label': 'Brings friends',
        },
        {
          'tagId': 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
          'label': 'Prefers weekends',
        },
      ],
      'notes': <Object?>[
        {
          'noteId': 'note-1',
          'body': 'Introduced three friends.',
          'authorUid': 'manager-1',
          'createdAtMillis': 1000,
          'updatedAtMillis': 2000,
          'revision': 2,
        },
      ],
      'notesTruncated': false,
      'sends': <Object?>[
        {
          'kind': 'campaign',
          'campaignId': 'campaign-1',
          'name': 'August invite',
          'messageClass': 'organizerPromotion',
          'deliveryStatus': 'delivered',
          'createdAtMillis': 3000,
          'sentAtMillis': 4000,
          'updatedAtMillis': 5000,
        },
      ],
      'sendsTruncated': false,
      'revision': 4,
    });

    expect(detail.manualTags.single.label, 'Brings friends');
    expect(detail.manualTagVocabulary, hasLength(2));
    expect(detail.notes.single.wasEdited, isTrue);
    expect(
      detail.sends.single.deliveryStatus,
      HostCustomerSendDeliveryStatus.delivered,
    );
  });

  test('manual tag is part of audience pagination query identity', () {
    const first = HostAudienceQuery(manualTagId: 'tag-1', cursor: 'cursor-1');
    const second = HostAudienceQuery(manualTagId: 'tag-2', cursor: 'cursor-1');

    expect(first, isNot(second));
    expect(first.copyWith(clearCursor: true).cursor, isNull);
    expect(first.copyWith(clearManualTag: true).manualTagId, isNull);
  });
}
