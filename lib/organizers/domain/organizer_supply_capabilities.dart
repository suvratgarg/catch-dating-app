enum OrganizerSupplyCapabilityMode { unclaimedReadOnly, claimedManaged }

enum OrganizerReviewPolicy { afterEventEnd, attendedEventOnly }

class OrganizerSupplyCapabilities {
  const OrganizerSupplyCapabilities({
    required this.mode,
    required this.bookable,
    required this.paymentsEnabled,
    required this.waitlistEnabled,
    required this.hostContactEnabled,
    required this.claimable,
    required this.reviewPolicy,
  });

  const OrganizerSupplyCapabilities.unclaimedReadOnly({this.claimable = true})
    : mode = OrganizerSupplyCapabilityMode.unclaimedReadOnly,
      bookable = false,
      paymentsEnabled = false,
      waitlistEnabled = false,
      hostContactEnabled = false,
      reviewPolicy = OrganizerReviewPolicy.afterEventEnd;

  const OrganizerSupplyCapabilities.claimedManaged()
    : mode = OrganizerSupplyCapabilityMode.claimedManaged,
      bookable = true,
      paymentsEnabled = true,
      waitlistEnabled = true,
      hostContactEnabled = true,
      claimable = false,
      reviewPolicy = OrganizerReviewPolicy.attendedEventOnly;

  factory OrganizerSupplyCapabilities.fromJson(Map<String, dynamic> json) {
    final mode = json['mode'] == 'claimed_managed'
        ? OrganizerSupplyCapabilityMode.claimedManaged
        : OrganizerSupplyCapabilityMode.unclaimedReadOnly;
    if (mode == OrganizerSupplyCapabilityMode.claimedManaged) {
      return const OrganizerSupplyCapabilities.claimedManaged();
    }
    return OrganizerSupplyCapabilities.unclaimedReadOnly(
      claimable: json['claimable'] == true,
    );
  }

  final OrganizerSupplyCapabilityMode mode;
  final bool bookable;
  final bool paymentsEnabled;
  final bool waitlistEnabled;
  final bool hostContactEnabled;
  final bool claimable;
  final OrganizerReviewPolicy reviewPolicy;

  bool reviewableAt({required DateTime eventEnd, required DateTime now}) {
    return reviewPolicy == OrganizerReviewPolicy.afterEventEnd &&
        !eventEnd.isAfter(now);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is OrganizerSupplyCapabilities &&
            mode == other.mode &&
            bookable == other.bookable &&
            paymentsEnabled == other.paymentsEnabled &&
            waitlistEnabled == other.waitlistEnabled &&
            hostContactEnabled == other.hostContactEnabled &&
            claimable == other.claimable &&
            reviewPolicy == other.reviewPolicy;
  }

  @override
  int get hashCode => Object.hash(
    mode,
    bookable,
    paymentsEnabled,
    waitlistEnabled,
    hostContactEnabled,
    claimable,
    reviewPolicy,
  );

  Map<String, dynamic> toJson() => {
    'mode': switch (mode) {
      OrganizerSupplyCapabilityMode.unclaimedReadOnly => 'unclaimed_read_only',
      OrganizerSupplyCapabilityMode.claimedManaged => 'claimed_managed',
    },
    'bookable': bookable,
    'paymentsEnabled': paymentsEnabled,
    'waitlistEnabled': waitlistEnabled,
    'hostContactEnabled': hostContactEnabled,
    'claimable': claimable,
    'reviewPolicy': switch (reviewPolicy) {
      OrganizerReviewPolicy.afterEventEnd => 'after_event_end',
      OrganizerReviewPolicy.attendedEventOnly => 'attended_event_only',
    },
  };
}

Object? readOrganizerSupplyCapabilities(
  Map<dynamic, dynamic> json,
  String key,
) {
  final stored = json[key];
  if (stored != null) return stored;
  final ownership = json['ownership'];
  final claim = json['claim'];
  final ownershipState = ownership is Map ? ownership['state'] : null;
  final claimState = claim is Map ? claim['state'] : null;
  final hasLegacyOwner =
      json['ownerUserId'] != null ||
      json['hostUserId'] != null ||
      (json['hostUserIds'] is List &&
          (json['hostUserIds'] as List).isNotEmpty) ||
      (json['hostProfiles'] is List &&
          (json['hostProfiles'] as List).isNotEmpty);
  final managed =
      hasLegacyOwner ||
      const {
        'userCreated',
        'claimed',
        'transferred',
      }.contains(ownershipState) ||
      const {'claimed', 'verified'}.contains(claimState);
  return managed
      ? const OrganizerSupplyCapabilities.claimedManaged().toJson()
      : OrganizerSupplyCapabilities.unclaimedReadOnly(
          claimable: claimState == 'unclaimed',
        ).toJson();
}
