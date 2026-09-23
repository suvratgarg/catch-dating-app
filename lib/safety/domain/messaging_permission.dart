import 'package:meta/meta.dart';

enum MessagingPermissionStatus { unknown, optedIn, optedOut }

@immutable
class MessagingPermission {
  const MessagingPermission({
    required this.organizerId,
    required this.organizerName,
    required this.status,
    required this.receiptId,
  });
  factory MessagingPermission.fromMap(
    Map<Object?, Object?> json, {
    String? organizerId,
    String? organizerName,
  }) => MessagingPermission(
    organizerId: organizerId,
    organizerName: organizerName,
    status: MessagingPermissionStatus.values.byName(json['status']! as String),
    receiptId: json['receiptId'] as String?,
  );
  final String? organizerId;
  final String? organizerName;
  final MessagingPermissionStatus status;
  final String? receiptId;
  String get key => organizerId == null ? 'catch' : 'organizer:$organizerId';
  String get scope => organizerId == null ? 'catch' : 'organizer';
}

@immutable
class MessagingPermissionPage {
  MessagingPermissionPage({
    required this.catchPermission,
    required Iterable<MessagingPermission> organizers,
    required this.nextCursor,
  }) : organizers = List.unmodifiable(organizers);
  factory MessagingPermissionPage.fromMap(Map<Object?, Object?> json) =>
      MessagingPermissionPage(
        catchPermission: MessagingPermission.fromMap(
          json['catchPreference']! as Map,
        ),
        organizers: (json['organizers']! as List).map((value) {
          final row = value as Map;
          return MessagingPermission.fromMap(
            row['preference']! as Map,
            organizerId: row['organizerId']! as String,
            organizerName: row['organizerName'] as String?,
          );
        }),
        nextCursor: json['nextCursor'] as String?,
      );
  final MessagingPermission catchPermission;
  final List<MessagingPermission> organizers;
  final String? nextCursor;
  MessagingPermission? permission(String key) => key == catchPermission.key
      ? catchPermission
      : organizers.where((row) => row.key == key).firstOrNull;
  MessagingPermissionPage replacing(MessagingPermission permission) =>
      MessagingPermissionPage(
        catchPermission: permission.organizerId == null
            ? permission
            : catchPermission,
        organizers: organizers.map(
          (row) => row.key == permission.key ? permission : row,
        ),
        nextCursor: nextCursor,
      );
}
