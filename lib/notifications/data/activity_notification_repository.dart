import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/notifications/domain/activity_notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'activity_notification_repository.g.dart';

class ActivityNotificationRepository {
  const ActivityNotificationRepository(this._db);

  static const _rootCollectionPath = 'notifications';
  static const _itemsCollectionPath = 'items';

  final FirebaseFirestore _db;

  CollectionReference<ActivityNotification> _itemsRef(String uid) => _db
      .collection(_rootCollectionPath)
      .doc(uid)
      .collection(_itemsCollectionPath)
      .withDocumentIdConverter<ActivityNotification>(
        idField: 'id',
        fromJson: ActivityNotification.fromJson,
        toJson: (notification) => notification.toJson(),
      );

  Stream<List<ActivityNotification>> watchActivity({
    required String uid,
    int limit = 50,
  }) => _itemsRef(uid)
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .snapshots()
      .map(
        (snap) => snap.docs
            .map((doc) => doc.data())
            .where((notification) => notification.isVisibleInActivity)
            .toList(),
      );

  Future<void> markAllRead({
    required String uid,
    required Iterable<ActivityNotification> notifications,
  }) async {
    final unread = notifications.where((notification) => notification.isUnread);
    await Future.wait(
      unread.map(
        (notification) => _itemsRef(
          uid,
        ).doc(notification.id).update({'readAt': FieldValue.serverTimestamp()}),
      ),
    );
  }
}

@riverpod
ActivityNotificationRepository activityNotificationRepository(Ref ref) =>
    ActivityNotificationRepository(ref.watch(firebaseFirestoreProvider));

@riverpod
Stream<List<ActivityNotification>> watchActivityNotifications(
  Ref ref,
  String uid,
) => ref.watch(activityNotificationRepositoryProvider).watchActivity(uid: uid);
