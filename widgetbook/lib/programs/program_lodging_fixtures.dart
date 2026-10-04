// Synthetic local Widgetbook data only; no guest import, booking or live reads.
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

Map<String, Object?> lodgingSetupCatalogJson() {
  final start = DateTime.utc(2026, 10, 1, 12).millisecondsSinceEpoch;
  final end = DateTime.utc(2026, 10, 3, 12).millisecondsSinceEpoch;
  return {
    'programId': 'program',
    'organizerId': 'organizer',
    'timezone': 'Asia/Kolkata',
    'calendarDates': {
      start.toString(): '2026-10-01',
      end.toString(): '2026-10-03',
    },
    'guests': [
      {
        'id': 'guest',
        'label': 'Guest',
        'householdId': 'household',
        'groupIds': ['friends'],
      },
      {
        'id': 'local',
        'label': 'Local guest',
        'householdId': 'household',
        'groupIds': ['friends'],
      },
    ],
    'groups': [
      {'id': 'friends', 'label': 'Friends'},
    ],
    'hotels': [
      {'id': 'hotel', 'label': 'Hotel', 'active': true},
    ],
    'contracts': [
      {
        'id': 'block',
        'hotelId': 'hotel',
        'label': 'Room block',
        'roomType': 'standard',
        'totalRooms': 2,
        'maxOccupantsPerRoom': 2,
        'startsAtMillis': start,
        'endsAtMillis': end,
      },
    ],
    'activeStays': <Object?>[],
  };
}

Map<String, Object?> lodgingSetupConfigurationJson() {
  final review = lodgingReviewJson();
  final snapshot = (review['context']! as Map)['snapshot']! as Map;
  final contract =
      (lodgingSetupCatalogJson()['contracts']! as List).single as Map;
  return {
    'programId': 'program',
    'organizerId': 'organizer',
    'revision': 1,
    'demand': [
      {
        'guestId': 'guest',
        'startsAtMillis': contract['startsAtMillis'],
        'endsAtMillis': contract['endsAtMillis'],
        'beds': 1,
        'requiredFeatures': <String>[],
      },
    ],
    'parties': [
      {
        'id': 'party',
        'guestIds': ['guest'],
        'confirmed': true,
        'priority': 0,
        'requiredRoomType': null,
        'pin': null,
      },
    ],
    'groupParents': <Object?>[],
    'rooms': snapshot['rooms'],
    'inventory': [
      {
        'id': 'unit',
        'physicalRoomId': 'room',
        'provisional': null,
        'contractId': 'block',
        'availability': [
          {'arrival': '2026-10-01', 'departure': '2026-10-03'},
        ],
      },
    ],
    'labels': [
      {'inventoryId': 'unit', 'roomLabel': '101'},
    ],
  };
}
