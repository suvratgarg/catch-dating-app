import 'package:catch_dating_app/dashboard/presentation/notifications_list_state.dart';
import 'package:catch_dating_app/notifications/domain/activity_notification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'pending invitations route to detail and accepted plans route to chat',
    () {
      final pending = ActivityNotification(
        id: 'notification-1',
        uid: 'runner-2',
        type: ActivityNotificationType.crossPathsInvitation,
        title: 'Invitation',
        body: 'Rhea invited you.',
        createdAt: DateTime.utc(2026, 8, 5),
        invitationId: 'invitation-1',
      );
      final accepted = pending.copyWith(
        type: ActivityNotificationType.crossPathsInvitationAccepted,
        matchId: 'plan-1',
      );

      expect(
        notificationRoute(pending),
        '/cross-paths/invitations/invitation-1',
      );
      expect(notificationRoute(accepted), '/chats/plan-1');
    },
  );
}
