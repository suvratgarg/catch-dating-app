import 'package:catch_dating_app/chats/domain/event_chat_profile.dart';
import 'package:catch_dating_app/user_profile/domain/form_profile.dart';
import 'package:flutter_test/flutter_test.dart';

EventProfileSettings settingsFixture({
  EventProfileSelection? selection,
  bool canShare = true,
  int revision = 1,
  int profileRevision = 2,
  int membershipRevision = 3,
}) => EventProfileSettings(
  eventId: 'event',
  organizerId: 'rsvp',
  revision: revision,
  selection: selection,
  canShare: canShare,
  profileRevision: profileRevision,
  membershipRevision: membershipRevision,
  coreFields: [
    EventProfileField(id: 'age', value: 32),
    EventProfileField(id: 'occupation', value: 'Founder'),
  ],
  photoIds: const ['photo'],
);

FormProfileReview cardFixture({
  String organizerId = 'rsvp',
  bool claimed = true,
  int revision = 4,
}) => FormProfileReview(
  responseId: 'response',
  organizerId: organizerId,
  formTitle: 'Dinner',
  organizerName: 'RSVP',
  profileRevision: 2,
  intakeRevision: 0,
  cardRevision: revision,
  claimedAt: claimed ? DateTime(2026) : null,
  termsVersion: 'form-profile-claim-v1',
  fields: [
    for (final id in ['drink', 'private', 'photo'])
      FormProfileField(
        questionId: id,
        destination: FormProfileDestination.organizerCard,
        canonicalFieldId: null,
        label: id,
        kind: id == 'photo' ? 'file' : 'shortText',
        value: id == 'photo' ? ['asset'] : 'Tequila',
      ),
  ],
  selectedCardQuestionIds: const ['drink', 'photo'],
  currentProfile: null,
  currentLinkedinUrl: null,
);

EventProfileSelection selectionFixture({
  int profileRevision = 2,
  int membershipRevision = 3,
  int cardRevision = 4,
  bool withCard = true,
}) => EventProfileSelection(
  profileRevision: profileRevision,
  membershipRevision: membershipRevision,
  coreFieldIds: const ['occupation', 'age'],
  photoId: 'photo',
  card: withCard
      ? EventProfileCardSelection(
          responseId: 'response',
          revision: cardRevision,
          questionIds: const ['drink'],
        )
      : null,
);

void main() {
  test(
    'joining or selecting an unshared card never checks fields automatically',
    () {
      final draft = EventProfileDraft(settingsFixture(), cardFixture());
      expect(draft.selection(), isNull);
      expect(draft.questionIds, isEmpty);
    },
  );
  test(
    'unchanged explicit choices restore and serialize stable pointer-only data',
    () {
      final saved = selectionFixture();
      final draft = EventProfileDraft(
        settingsFixture(selection: saved),
        cardFixture(),
      );
      expect(draft.selection()!.toJson(), saved.toJson());
      expect(
        draft.selection()!.toJson().toString(),
        isNot(contains('Tequila')),
      );
      expect(
        EventProfileSelection.fromMap(saved.toJson()).toJson(),
        saved.toJson(),
      );
    },
  );
  test('a core-only choice does not dereference a missing card', () {
    final saved = selectionFixture(withCard: false);
    final draft = EventProfileDraft(settingsFixture(selection: saved), null);
    expect(draft.selection()!.coreFieldIds, {'age', 'occupation'});
    expect(draft.selection()!.card, isNull);
  });
  test(
    'edited profile, card and membership revisions each clear affected choices',
    () {
      final saved = selectionFixture();
      final core = EventProfileDraft(
        settingsFixture(selection: saved, profileRevision: 3),
        cardFixture(),
      );
      expect(core.coreFieldIds, isEmpty);
      expect(core.photoId, isNull);
      expect(core.questionIds, {'drink'});
      final card = EventProfileDraft(
        settingsFixture(selection: saved),
        cardFixture(revision: 5),
      );
      expect(card.questionIds, isEmpty);
      expect(card.coreFieldIds, hasLength(2));
      final rejoin = EventProfileDraft(
        settingsFixture(selection: saved, membershipRevision: 4),
        cardFixture(),
      );
      expect(rejoin.selection(), isNull);
    },
  );
  test(
    'foreign, unclaimed, file and unselected applicant fields are unavailable',
    () {
      expect(
        eventCardFields(cardFixture(organizerId: 'other'), 'rsvp'),
        isEmpty,
      );
      expect(eventCardFields(cardFixture(claimed: false), 'rsvp'), isEmpty);
      expect(eventCardFields(cardFixture(), 'rsvp').map((f) => f.questionId), [
        'drink',
      ]);
    },
  );
  test('payload snapshots are immutable after the editor changes', () {
    final draft = EventProfileDraft(settingsFixture(), cardFixture());
    draft.coreFieldIds.add('age');
    draft.questionIds.add('drink');
    final snapshot = draft.selection()!;
    draft.coreFieldIds.clear();
    draft.questionIds.clear();
    expect(snapshot.coreFieldIds, {'age'});
    expect(snapshot.card!.questionIds, {'drink'});
    expect(() => snapshot.coreFieldIds.add('email'), throwsUnsupportedError);
  });
  test(
    'mini-profile parser accepts only a bounded JPEG preview, never a URL',
    () {
      final json = {
        'eventId': 'event',
        'participantUid': 'sara',
        'displayName': 'Sara',
        'coreFields': [
          {'fieldId': 'age', 'value': 32},
        ],
        'cardFields': [
          {'label': 'Favourite drink', 'value': 'Tequila'},
        ],
        'photo': null,
      };
      final parsed = EventParticipantProfile.fromMap(json);
      expect(parsed.coreFields.single.id, 'age');
      expect(parsed.cardFields.single.value, 'Tequila');
      expect(
        () => EventParticipantProfile.fromMap({
          ...json,
          'photo': const {'url': 'https://example.test/private.jpg'},
        }),
        throwsFormatException,
      );
    },
  );
}
