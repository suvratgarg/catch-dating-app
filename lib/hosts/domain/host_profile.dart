import 'package:cloud_firestore/cloud_firestore.dart';

enum HostProfileStatus { active, pending, suspended }

class HostProfile {
  const HostProfile({
    required this.uid,
    required this.displayName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.avatarUrl,
    this.roleTitle,
    this.bio,
    this.verified = false,
    this.linkedClubIds = const [],
  });

  final String uid;
  final String displayName;
  final String? avatarUrl;
  final String? roleTitle;
  final String? bio;
  final HostProfileStatus status;
  final bool verified;
  final List<String> linkedClubIds;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isActive => status == HostProfileStatus.active;

  factory HostProfile.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return HostProfile(
      uid: doc.id,
      displayName: _string(data['displayName']) ?? 'Catch Host',
      avatarUrl: _string(data['avatarUrl']),
      roleTitle: _string(data['roleTitle']),
      bio: _string(data['bio']),
      status: _status(data['status']),
      verified: data['verified'] == true,
      linkedClubIds: [
        for (final value in data['linkedClubIds'] as List? ?? const [])
          if (value is String && value.isNotEmpty) value,
      ],
      createdAt: _timestampDate(data['createdAt']),
      updatedAt: _timestampDate(data['updatedAt']),
    );
  }
}

String? _string(Object? value) {
  if (value is! String) return null;
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

HostProfileStatus _status(Object? value) {
  return switch (value) {
    'pending' => HostProfileStatus.pending,
    'suspended' => HostProfileStatus.suspended,
    _ => HostProfileStatus.active,
  };
}

DateTime? _timestampDate(Object? value) {
  if (value is Timestamp) return value.toDate();
  return null;
}
