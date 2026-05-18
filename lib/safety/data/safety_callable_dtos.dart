final class BlockUserCallableRequest {
  const BlockUserCallableRequest({
    required this.targetUserId,
    required this.source,
  });

  final String targetUserId;
  final String source;

  Map<String, Object?> toJson() => {
    'targetUserId': targetUserId,
    'source': source,
  };
}

final class UnblockUserCallableRequest {
  const UnblockUserCallableRequest({required this.targetUserId});

  final String targetUserId;

  Map<String, Object?> toJson() => {'targetUserId': targetUserId};
}

final class ReportUserCallableRequest {
  const ReportUserCallableRequest({
    required this.targetUserId,
    required this.source,
    this.reasonCode,
    this.contextId,
    this.notes,
  });

  final String targetUserId;
  final String source;
  final String? reasonCode;
  final String? contextId;
  final String? notes;

  Map<String, Object?> toJson() => {
    'targetUserId': targetUserId,
    'source': source,
    'reasonCode': ?reasonCode,
    'contextId': ?contextId,
    'notes': ?notes,
  };
}
