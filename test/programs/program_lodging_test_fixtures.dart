import 'package:catch_dating_app/programs/data/program_lodging_repository.dart';
import 'package:catch_dating_app/programs/domain/program_lodging_review.dart';
import 'package:flutter_test/flutter_test.dart';

final lodgingFixtureId = List.filled(64, 'a').join();
Map<String, Object?> lodgingReviewJson() {
  final revisions = {'source': 1, 'inventory': 1, 'layout': 1, 'published': 0};
  final scope = {'programId': 'program', 'organizerId': 'organizer'};
  return {
    'kind': 'proposal',
    'proposal': {
      'id': lodgingFixtureId,
      'scope': scope,
      'revisions': revisions,
      'placements': [
        {'partyId': 'party', 'inventoryId': 'unit'},
      ],
      'unplacedPartyIds': <Object?>[],
      'explanations': <Object?>[],
      'score': [0, 0],
      'search': {'complete': true, 'explored': 1},
    },
    'context': {
      'snapshot': {
        'scope': Map.of(scope),
        'revisions': Map.of(revisions),
        'parties': [
          {
            'id': 'party',
            'guestIds': ['guest'],
          },
        ],
        'published': [
          {
            'partyId': 'party',
            'inventoryId': 'unit',
            'locked': false,
            'checkedIn': false,
          },
        ],
        'rooms': [
          {
            'id': 'room',
            'hotelId': 'hotel',
            'zoneId': 'zone',
            'building': 'Building',
            'floor': '1',
            'wing': 'A',
            'roomType': 'standard',
            'beds': 1,
            'maxOccupants': 1,
            'verifiedFeatures': <Object?>[],
            'resourceIds': ['room'],
            'position': {'x': 0.5, 'y': 0.5},
          },
        ],
        'inventory': [
          {
            'id': 'unit',
            'physicalRoomId': 'room',
            'provisional': null,
            'contractId': 'block',
            'availability': [],
          },
        ],
      },
      'configuration': {
        ...scope,
        'labels': [
          {'inventoryId': 'unit', 'roomLabel': '101'},
        ],
      },
      'workflow': {
        'revision': 1,
        'approvedProposalId': lodgingFixtureId,
        'confirmedHotelIds': [],
        'guestPublishedProposalId': null,
      },
      'labels': {
        'guests': {'guest': 'Guest'},
        'hotels': {'hotel': 'Hotel'},
        'groups': {},
      },
      'accessExpiresAtMillis': null,
    },
  };
}

class FakeLodgingRepository extends Fake implements ProgramLodgingRepository {
  ProgramLodgingReview current = ProgramLodgingReview.fromCallableData(
    lodgingReviewJson(),
  );
  bool hasSetup = true;
  Future<ProgramLodgingReview>? pendingPreview;
  Object? previewFailure;
  Object? transitionFailure;
  Future<ProgramLodgingProposal>? pendingSave;
  Future<Map<String, Object?>>? pendingTransition;
  var previews = 0;
  var saves = 0;
  final commands = <Map<String, Object?>>[];

  @override
  Future<ProgramLodgingSetup> readSetup(String programId) async =>
      ProgramLodgingSetup(
        configuration: hasSetup ? current.configuration : null,
        accessExpiresAt: null,
      );
  @override
  Future<ProgramLodgingReview> preview(String programId) async {
    previews++;
    if (previewFailure != null) throw previewFailure!;
    return pendingPreview ?? current;
  }

  @override
  Future<ProgramLodgingProposal> save(
    String programId,
    ProgramLodgingProposal proposal,
  ) async {
    saves++;
    return pendingSave ?? proposal;
  }

  @override
  Future<Map<String, Object?>> transition(
    String programId, {
    required ProgramLodgingProposal proposal,
    required String operationId,
    required int expectedWorkflowRevision,
    required ProgramLodgingAction action,
    String? hotelId,
  }) async {
    commands.add({
      'programId': programId,
      'proposalId': proposal.id,
      'operationId': operationId,
      'expectedWorkflowRevision': expectedWorkflowRevision,
      'action': action.name,
      'hotelId': hotelId,
    });
    if (pendingTransition != null) return pendingTransition!;
    if (transitionFailure != null) throw transitionFailure!;
    return {
      'kind': 'transition',
      'workflow': {'revision': expectedWorkflowRevision + 1},
      'receipt': {},
      'replayed': false,
    };
  }
}
