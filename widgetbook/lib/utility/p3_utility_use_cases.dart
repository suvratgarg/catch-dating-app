import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/auth/presentation/auth_session_controller.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/dashboard/presentation/activity_screen.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/activity_section.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_detail_view_model.dart';
import 'package:catch_dating_app/events/presentation/event_location_map_screen.dart';
import 'package:catch_dating_app/labs/design_fixtures/utility_surface_fixtures.dart';
import 'package:catch_dating_app/notifications/data/activity_notification_repository.dart';
import 'package:catch_dating_app/notifications/domain/activity_notification.dart';
import 'package:catch_dating_app/payments/data/payment_history_repository.dart';
import 'package:catch_dating_app/payments/domain/payment.dart';
import 'package:catch_dating_app/payments/presentation/payment_history_screen.dart';
import 'package:catch_dating_app/public_profile/data/public_profiles_lookup.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/presentation/reviews_history_screen.dart';
import 'package:catch_dating_app/reviews/presentation/write_review_sheet.dart';
import 'package:catch_dating_app/safety/data/safety_repository.dart';
import 'package:catch_dating_app/safety/presentation/settings_controller.dart';
import 'package:catch_dating_app/safety/presentation/settings_screen.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const _viewerUid = UtilitySurfaceFixtures.viewerUid;
final _viewer = UtilitySurfaceFixtures.viewer;
final _event = UtilitySurfaceFixtures.event;
final _eventWithoutCoordinate = UtilitySurfaceFixtures.eventWithoutCoordinate;
final _payments = UtilitySurfaceFixtures.payments;
final _reviews = UtilitySurfaceFixtures.reviews;
final _notifications = UtilitySurfaceFixtures.notifications;

@widgetbook.UseCase(
  name: 'Route states',
  type: EventLocationMapRouteScreen,
  path: '[P3 utility surfaces]/Event location map',
)
Widget eventLocationMapRouteStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'EventLocationMapRouteScreen',
    contractId: 'screen.event.location_map',
    children: [
      _StateCard(
        label: 'route loading',
        child: _DeviceFrame(
          child: _MapRouteScope(
            value: const AsyncLoading<EventDetailViewModel?>(),
            child: EventLocationMapRouteScreen(
              eventId: _event.id,
              enableNetworkTiles: false,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'route error',
        child: _DeviceFrame(
          child: _MapRouteScope(
            value: AsyncError<EventDetailViewModel?>(
              StateError('Widgetbook event lookup failed'),
              StackTrace.empty,
            ),
            child: EventLocationMapRouteScreen(
              eventId: _event.id,
              enableNetworkTiles: false,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'event not found',
        child: _DeviceFrame(
          child: _MapRouteScope(
            value: const AsyncData<EventDetailViewModel?>(null),
            child: EventLocationMapRouteScreen(
              eventId: _event.id,
              enableNetworkTiles: false,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'pinned location',
        child: _DeviceFrame(
          child: _MapRouteScope(
            value: AsyncData<EventDetailViewModel?>(_eventVm(_event)),
            child: EventLocationMapRouteScreen(
              eventId: _event.id,
              enableNetworkTiles: false,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Map states',
  type: EventLocationMapScreen,
  path: '[P3 utility surfaces]/Event location map',
)
Widget eventLocationMapScreenStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'EventLocationMapScreen',
    contractId: 'screen.event.location_map.sections',
    children: [
      _StateCard(
        label: 'network tiles disabled',
        child: _DeviceFrame(
          child: _ExternalLinkScope(
            child: EventLocationMapScreen(
              event: _event,
              enableNetworkTiles: false,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'no exact coordinate',
        child: _DeviceFrame(
          child: EventLocationMapScreen(
            event: _eventWithoutCoordinate,
            enableNetworkTiles: false,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Screen states',
  type: ActivityScreen,
  path: '[P3 utility surfaces]/Notifications',
)
Widget activityScreenStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'ActivityScreen',
    contractId: 'screen.notifications.list',
    children: [
      _StateCard(
        label: 'uid loading',
        child: _DeviceFrame(
          child: _ActivityScreenScope(
            uidStream: _loadingStream<String?>(),
            notificationsStream: Stream.value(_notifications),
            child: const ActivityScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'signed out',
        child: _DeviceFrame(
          child: _ActivityScreenScope(
            uidStream: Stream<String?>.value(null),
            notificationsStream: Stream.value(_notifications),
            child: const ActivityScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'mark-all-read visible',
        child: _DeviceFrame(
          child: _ActivityScreenScope(
            notificationsStream: Stream.value(_notifications),
            child: const ActivityScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'activity error',
        child: _DeviceFrame(
          child: _ActivityScreenScope(
            notificationsStream: _errorStream('Activity stream failed'),
            child: const ActivityScreen(),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Section states',
  type: ActivitySection,
  path: '[P3 utility surfaces]/Notifications',
)
Widget activitySectionStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'ActivitySection',
    contractId: 'screen.notifications.list.activity_body',
    children: [
      _StateCard(
        label: 'loading',
        child: _ActivitySectionScope(
          notificationsStream: _loadingStream<List<ActivityNotification>>(),
          child: const ActivitySection(uid: _viewerUid),
        ),
      ),
      _StateCard(
        label: 'empty',
        child: _ActivitySectionScope(
          notificationsStream: Stream.value(const <ActivityNotification>[]),
          child: const ActivitySection(uid: _viewerUid),
        ),
      ),
      _StateCard(
        label: 'error',
        child: _ActivitySectionScope(
          notificationsStream: _errorStream('Activity unavailable'),
          child: const ActivitySection(uid: _viewerUid),
        ),
      ),
      _StateCard(
        label: 'grouped read and unread',
        child: _ActivitySectionScope(
          notificationsStream: Stream.value(_notifications),
          child: const ActivitySection(uid: _viewerUid),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Row states',
  type: NotificationRow,
  path: '[P3 utility surfaces]/Notifications',
)
Widget notificationRowStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'NotificationRow',
    contractId: 'screen.notifications.list.row',
    children: [
      _StateCard(
        label: 'unread event reminder',
        child: const NotificationRow(
          type: ActivityNotificationType.eventReminder,
          title: 'Event starts tomorrow',
          time: '2h',
          body: 'Sundowner 5K meets at Carter Road Jetty.',
          unread: true,
          onTap: _noop,
        ),
      ),
      _StateCard(
        label: 'read signup',
        child: const NotificationRow(
          type: ActivityNotificationType.eventSignup,
          title: 'You are booked',
          time: '5h',
          body: 'Your spot is confirmed for Wednesday evening.',
          divider: true,
          onTap: _noop,
        ),
      ),
      _StateCard(
        label: 'long copy',
        child: const NotificationRow(
          type: ActivityNotificationType.clubUpdate,
          title: 'Sea Face Social added a new slower return-to-running loop',
          time: 'yesterday',
          body:
              'The host posted pacing notes, regroup points, and cafe timing for members returning after a break.',
          unread: true,
          divider: true,
          onTap: _noop,
        ),
      ),
      _StateCard(
        label: 'non-navigable cancellation',
        child: const NotificationRow(
          type: ActivityNotificationType.eventCancelled,
          title: 'Morning run was cancelled',
          time: 'mon',
          body: 'Heavy rain moved the session to next week.',
          divider: true,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Screen states',
  type: ReviewsHistoryScreen,
  path: '[P3 utility surfaces]/Reviews history',
)
Widget reviewsHistoryScreenStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'ReviewsHistoryScreen',
    contractId: 'screen.reviews.history',
    children: [
      _StateCard(
        label: 'signed out',
        child: _DeviceFrame(
          child: _ReviewsScope(
            uidStream: Stream<String?>.value(null),
            profileStream: Stream.value(null),
            reviewsStream: Stream.value(_reviews),
            child: const ReviewsHistoryScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'profile loading',
        child: _DeviceFrame(
          child: _ReviewsScope(
            profileStream: _loadingStream<UserProfile?>(),
            reviewsStream: Stream.value(_reviews),
            child: const ReviewsHistoryScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'profile error',
        child: _DeviceFrame(
          child: _ReviewsScope(
            profileStream: _errorStream('Profile failed'),
            reviewsStream: Stream.value(_reviews),
            child: const ReviewsHistoryScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'reviews loading',
        child: _DeviceFrame(
          child: _ReviewsScope(
            reviewsStream: _loadingStream<List<Review>>(),
            child: const ReviewsHistoryScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'reviews error',
        child: _DeviceFrame(
          child: _ReviewsScope(
            reviewsStream: _errorStream('Reviews failed'),
            child: const ReviewsHistoryScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'empty reviews',
        child: _DeviceFrame(
          child: _ReviewsScope(
            reviewsStream: Stream.value(const <Review>[]),
            child: const ReviewsHistoryScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'review list with event context',
        child: _DeviceFrame(
          child: _ReviewsScope(
            reviewsStream: Stream.value(_reviews),
            eventsStream: Stream.value([_event]),
            child: const ReviewsHistoryScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'event context missing',
        child: _DeviceFrame(
          child: _ReviewsScope(
            reviewsStream: Stream.value(_reviews.take(1).toList()),
            eventsStream: Stream.value(const <Event>[]),
            child: const ReviewsHistoryScreen(),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Sheet states',
  type: WriteReviewSheet,
  path: '[P3 utility surfaces]/Reviews history',
)
Widget writeReviewSheetStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'WriteReviewSheet',
    contractId: 'screen.reviews.history.edit_sheet',
    children: [
      _StateCard(
        label: 'write review',
        child: _SheetFrame(
          child: IgnorePointer(
            child: WriteReviewSheet(
              clubId: 'widgetbook-club',
              eventId: _event.id,
              reviewer: _viewer,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'edit review with delete action',
        child: _SheetFrame(
          child: IgnorePointer(
            child: WriteReviewSheet(
              clubId: 'widgetbook-club',
              eventId: _event.id,
              reviewer: _viewer,
              existingReview: _reviews.first,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Screen states',
  type: SettingsScreen,
  path: '[P3 utility surfaces]/Settings',
)
Widget settingsScreenStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'SettingsScreen',
    contractId: 'screen.settings.account',
    children: [
      _StateCard(
        label: 'profile-backed account',
        child: _DeviceFrame(
          child: _SettingsScope(
            blockedUsersStream: Stream.value(const <BlockedUser>[]),
            child: const SettingsScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'profile loading',
        child: _DeviceFrame(
          child: _SettingsScope(
            profileStream: _loadingStream<UserProfile?>(),
            blockedUsersStream: Stream.value(const <BlockedUser>[]),
            child: const SettingsScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'blocked accounts loading',
        child: _DeviceFrame(
          child: _SettingsScope(
            blockedUsersStream: _loadingStream<List<BlockedUser>>(),
            child: const SettingsScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'blocked accounts error',
        child: _DeviceFrame(
          child: _SettingsScope(
            blockedUsersStream: _errorStream('Blocked users failed'),
            child: const SettingsScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'blocked accounts list',
        child: _DeviceFrame(
          child: _SettingsScope(
            blockedUsersStream: Stream.value(_blockedUsers),
            publicProfiles: UtilitySurfaceFixtures.blockedPublicProfiles,
            child: const SettingsScreen(),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Dialog states',
  type: CatchConfirmDialog,
  path: '[P3 utility surfaces]/Settings',
)
Widget settingsDangerDialogStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'CatchConfirmDialog',
    contractId: 'screen.settings.account.destructive_dialog',
    children: [
      _StateCard(
        label: 'delete account confirmation',
        child: const _DialogFrame(
          child: CatchConfirmDialog<bool>(
            title: 'Delete account?',
            message:
                'This removes your public profile, signs you out, and keeps only the minimal records required for safety and payment history.',
            actions: [
              CatchDialogAction(label: 'Cancel', value: false),
              CatchDialogAction(
                label: 'Delete',
                value: true,
                isDestructive: true,
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'sign out confirmation pattern',
        child: const _DialogFrame(
          child: CatchConfirmDialog<bool>(
            title: 'Log out?',
            message: 'You can sign back in with your phone number.',
            actions: [
              CatchDialogAction(label: 'Cancel', value: false),
              CatchDialogAction(label: 'Log out', value: true),
            ],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Mutation states',
  type: SettingsScreen,
  path: '[P3 utility surfaces]/Settings',
)
Widget settingsMutationStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'SettingsScreen mutation lifecycle',
    contractId: 'screen.settings.account.mutations',
    children: [
      _StateCard(
        label: 'preference save pending',
        child: _DeviceFrame(
          child: _SettingsScope(
            blockedUsersStream: Stream.value(const <BlockedUser>[]),
            child: const _SettingsMutationSeeder(
              mode: _SettingsMutationMode.preferencePending,
              child: SettingsScreen(),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'preference save error',
        child: _DeviceFrame(
          child: _SettingsScope(
            blockedUsersStream: Stream.value(const <BlockedUser>[]),
            child: const _SettingsMutationSeeder(
              mode: _SettingsMutationMode.preferenceError,
              child: SettingsScreen(),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'delete account pending',
        child: _DeviceFrame(
          child: _SettingsScope(
            blockedUsersStream: Stream.value(const <BlockedUser>[]),
            child: const _SettingsMutationSeeder(
              mode: _SettingsMutationMode.deletePending,
              child: SettingsScreen(),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'delete account error',
        child: _DeviceFrame(
          child: _SettingsScope(
            blockedUsersStream: Stream.value(const <BlockedUser>[]),
            child: const _SettingsMutationSeeder(
              mode: _SettingsMutationMode.deleteError,
              child: SettingsScreen(),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'sign out pending',
        child: _DeviceFrame(
          child: _SettingsScope(
            blockedUsersStream: Stream.value(const <BlockedUser>[]),
            child: const _SettingsMutationSeeder(
              mode: _SettingsMutationMode.signOutPending,
              child: SettingsScreen(),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'unblock user error',
        child: _DeviceFrame(
          child: _SettingsScope(
            blockedUsersStream: Stream.value(_blockedUsers),
            publicProfiles: UtilitySurfaceFixtures.blockedPublicProfiles,
            child: const _SettingsMutationSeeder(
              mode: _SettingsMutationMode.unblockError,
              child: SettingsScreen(),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Screen states',
  type: PaymentHistoryScreen,
  path: '[P3 utility surfaces]/Payment history',
)
Widget paymentHistoryScreenStates(BuildContext context) {
  return _UtilityCatalog(
    title: 'PaymentHistoryScreen',
    contractId: 'screen.payments.history',
    children: [
      _StateCard(
        label: 'uid loading',
        child: _DeviceFrame(
          child: _PaymentScope(
            uidStream: _loadingStream<String?>(),
            paymentsStream: Stream.value(_payments),
            child: const PaymentHistoryScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'uid error',
        child: _DeviceFrame(
          child: _PaymentScope(
            uidStream: _errorStream('Auth session failed'),
            paymentsStream: Stream.value(_payments),
            child: const PaymentHistoryScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'signed out',
        child: _DeviceFrame(
          child: _PaymentScope(
            uidStream: Stream<String?>.value(null),
            paymentsStream: Stream.value(_payments),
            child: const PaymentHistoryScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'payments loading',
        child: _DeviceFrame(
          child: _PaymentScope(
            paymentsStream: _loadingStream<List<Payment>>(),
            child: const PaymentHistoryScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'payments error',
        child: _DeviceFrame(
          child: _PaymentScope(
            paymentsStream: _errorStream('Payments failed'),
            child: const PaymentHistoryScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'empty history',
        child: _DeviceFrame(
          child: _PaymentScope(
            paymentsStream: Stream.value(const <Payment>[]),
            child: const PaymentHistoryScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'status variants',
        child: _DeviceFrame(
          child: _PaymentScope(
            paymentsStream: Stream.value(_payments),
            eventsById: {
              for (final payment in _payments)
                payment.eventId: _utilityEvent(
                  id: payment.eventId,
                  meetingPoint: _eventTitleForPayment(payment),
                  notes: 'Receipt context',
                  latitude: 19.0676,
                  longitude: 72.8227,
                ),
            },
            child: const PaymentHistoryScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'event title missing',
        child: _DeviceFrame(
          child: _PaymentScope(
            paymentsStream: Stream.value(_payments.take(1).toList()),
            eventsById: const {},
            child: const PaymentHistoryScreen(),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Receipt states',
  type: PaymentReceiptSheet,
  path: '[P3 utility surfaces]/Payment history',
)
Widget paymentReceiptSheetStates(BuildContext context) {
  final failedPayment = _payments.firstWhere(
    (payment) => payment.status == PaymentStatus.refundFailed,
  );
  return _UtilityCatalog(
    title: 'PaymentReceiptSheet',
    contractId: 'screen.payments.history.detail_sheet',
    children: [
      _StateCard(
        label: 'paid receipt',
        child: _SheetFrame(
          child: PaymentReceiptSheet(
            payment: _payments.first,
            eventTitle: 'Sundowner 5K receipt',
          ),
        ),
      ),
      _StateCard(
        label: 'failed signup help',
        child: _SheetFrame(
          child: PaymentReceiptSheet(
            payment: failedPayment,
            eventTitle: 'Refund needs attention',
            onHelp: _noop,
          ),
        ),
      ),
    ],
  );
}

enum _SettingsMutationMode {
  preferencePending,
  preferenceError,
  deletePending,
  deleteError,
  signOutPending,
  unblockError,
}

class _SettingsMutationSeeder extends ConsumerStatefulWidget {
  const _SettingsMutationSeeder({required this.mode, required this.child});

  final _SettingsMutationMode mode;
  final Widget child;

  @override
  ConsumerState<_SettingsMutationSeeder> createState() =>
      _SettingsMutationSeederState();
}

class _SettingsMutationSeederState
    extends ConsumerState<_SettingsMutationSeeder> {
  Completer<void>? _pendingCompleter;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _started) return;
      _started = true;
      _seed();
    });
  }

  @override
  void dispose() {
    final completer = _pendingCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
    super.dispose();
  }

  void _seed() {
    switch (widget.mode) {
      case _SettingsMutationMode.preferencePending:
        _runPending(SettingsController.savePreferenceMutation);
        break;
      case _SettingsMutationMode.preferenceError:
        _runError(
          SettingsController.savePreferenceMutation,
          'Preference save failed',
        );
        break;
      case _SettingsMutationMode.deletePending:
        _runPending(SettingsController.requestAccountDeletionMutation);
        break;
      case _SettingsMutationMode.deleteError:
        _runError(
          SettingsController.requestAccountDeletionMutation,
          'Delete account failed',
        );
        break;
      case _SettingsMutationMode.signOutPending:
        _runPending(AuthSessionController.signOutMutation);
        break;
      case _SettingsMutationMode.unblockError:
        _runError(SettingsController.unblockUserMutation, 'Unblock failed');
        break;
    }
  }

  void _runPending(Mutation<void> mutation) {
    final completer = Completer<void>();
    _pendingCompleter = completer;
    unawaited(mutation.run(ref, (_) => completer.future));
  }

  void _runError(Mutation<void> mutation, String message) {
    unawaited(
      mutation
          .run(ref, (_) async => throw StateError(message))
          .catchError((_) {}),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _MapRouteScope extends StatelessWidget {
  const _MapRouteScope({required this.value, required this.child});

  final AsyncValue<EventDetailViewModel?> value;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        eventDetailViewModelProvider(_event.id).overrideWithValue(value),
        externalUrlLauncherProvider.overrideWithValue(_noopLauncher),
      ],
      child: child,
    );
  }
}

class _ExternalLinkScope extends StatelessWidget {
  const _ExternalLinkScope({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [externalUrlLauncherProvider.overrideWithValue(_noopLauncher)],
      child: child,
    );
  }
}

class _ActivityScreenScope extends StatelessWidget {
  const _ActivityScreenScope({
    required this.child,
    required this.notificationsStream,
    this.uidStream,
  });

  final Widget child;
  final Stream<String?>? uidStream;
  final Stream<List<ActivityNotification>> notificationsStream;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        uidProvider.overrideWith(
          (ref) => uidStream ?? Stream<String?>.value(_viewerUid),
        ),
        watchActivityNotificationsProvider(
          _viewerUid,
        ).overrideWith((ref) => notificationsStream),
      ],
      child: child,
    );
  }
}

class _ActivitySectionScope extends StatelessWidget {
  const _ActivitySectionScope({
    required this.notificationsStream,
    required this.child,
  });

  final Stream<List<ActivityNotification>> notificationsStream;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        watchActivityNotificationsProvider(
          _viewerUid,
        ).overrideWith((ref) => notificationsStream),
      ],
      child: child,
    );
  }
}

class _ReviewsScope extends StatelessWidget {
  const _ReviewsScope({
    required this.child,
    this.uidStream,
    this.profileStream,
    this.reviewsStream,
    this.eventsStream,
  });

  final Widget child;
  final Stream<String?>? uidStream;
  final Stream<UserProfile?>? profileStream;
  final Stream<List<Review>>? reviewsStream;
  final Stream<List<Event>>? eventsStream;

  @override
  Widget build(BuildContext context) {
    final eventIds = <String>{
      for (final review in _reviews)
        if (review.eventId != null) review.eventId!,
    };
    return ProviderScope(
      overrides: [
        uidProvider.overrideWith(
          (ref) => uidStream ?? Stream<String?>.value(_viewerUid),
        ),
        watchUserProfileProvider.overrideWith(
          (ref) => profileStream ?? Stream<UserProfile?>.value(_viewer),
        ),
        watchReviewsByUserProvider(
          _viewerUid,
        ).overrideWith((ref) => reviewsStream ?? Stream.value(_reviews)),
        watchEventsByIdsProvider(
          EventsByIdQuery(eventIds),
        ).overrideWith((ref) => eventsStream ?? Stream.value([_event])),
      ],
      child: child,
    );
  }
}

class _SettingsScope extends StatelessWidget {
  const _SettingsScope({
    required this.child,
    this.profileStream,
    this.blockedUsersStream,
    this.publicProfiles = const {},
  });

  final Widget child;
  final Stream<UserProfile?>? profileStream;
  final Stream<List<BlockedUser>>? blockedUsersStream;
  final Map<String, PublicProfile> publicProfiles;

  @override
  Widget build(BuildContext context) {
    final query = PublicProfilesQuery(
      _blockedUsers.map((blocked) => blocked.uid),
    );
    return ProviderScope(
      overrides: [
        uidProvider.overrideWith((ref) => Stream<String?>.value(_viewerUid)),
        watchUserProfileProvider.overrideWith(
          (ref) => profileStream ?? Stream<UserProfile?>.value(_viewer),
        ),
        watchBlockedUsersProvider.overrideWith(
          (ref) => blockedUsersStream ?? Stream.value(const <BlockedUser>[]),
        ),
        publicProfilesByIdsProvider(
          query,
        ).overrideWith((ref) async => publicProfiles),
        externalUrlLauncherProvider.overrideWithValue(_noopLauncher),
      ],
      child: child,
    );
  }
}

class _PaymentScope extends StatelessWidget {
  const _PaymentScope({
    required this.child,
    this.uidStream,
    this.paymentsStream,
    this.eventsById,
  });

  final Widget child;
  final Stream<String?>? uidStream;
  final Stream<List<Payment>>? paymentsStream;
  final Map<String, Event>? eventsById;

  @override
  Widget build(BuildContext context) {
    final payments = _payments;
    final eventOverrides = [
      for (final payment in payments)
        watchEventProvider(payment.eventId).overrideWith(
          (ref) => Stream<Event?>.value(eventsById?[payment.eventId]),
        ),
    ];
    return ProviderScope(
      overrides: [
        uidProvider.overrideWith(
          (ref) => uidStream ?? Stream<String?>.value(_viewerUid),
        ),
        watchPaymentsForUserProvider(
          _viewerUid,
        ).overrideWith((ref) => paymentsStream ?? Stream.value(_payments)),
        ...eventOverrides,
      ],
      child: child,
    );
  }
}

class _UtilityCatalog extends StatelessWidget {
  const _UtilityCatalog({
    required this.title,
    required this.contractId,
    required this.children,
  });

  final String title;
  final String contractId;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: ListView(
          padding: CatchInsets.content,
          children: [
            Text(title, style: CatchTextStyles.titleL(context)),
            gapH4,
            Text(
              contractId,
              style: CatchTextStyles.monoLabel(context, color: t.ink2),
            ),
            gapH24,
            for (final child in children) ...[child, gapH20],
          ],
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(CatchRadius.lg),
      ),
      child: Padding(
        padding: CatchInsets.content,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: CatchTextStyles.sectionTitle(context)),
            gapH12,
            child,
          ],
        ),
      ),
    );
  }
}

class _DeviceFrame extends StatelessWidget {
  const _DeviceFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: t.surface,
            border: Border.all(color: t.line),
            borderRadius: BorderRadius.circular(CatchRadius.lg),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(CatchRadius.lg),
            child: SizedBox(height: 720, child: child),
          ),
        ),
      ),
    );
  }
}

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: t.bg,
            border: Border.all(color: t.line),
            borderRadius: BorderRadius.circular(CatchRadius.lg),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(CatchRadius.lg),
            child: SizedBox(
              height: 560,
              child: Align(alignment: Alignment.bottomCenter, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogFrame extends StatelessWidget {
  const _DialogFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return ColoredBox(
      color: t.ink.withValues(alpha: CatchOpacity.confirmDialogScrim),
      child: SizedBox(height: 360, child: Center(child: child)),
    );
  }
}

EventDetailViewModel _eventVm(Event event) => EventDetailViewModel(
  event: event,
  userProfile: _viewer,
  reviews: const [],
  isAuthenticated: true,
  isHost: false,
  isSaved: false,
  participation: null,
);

Event _utilityEvent({
  required String id,
  required String meetingPoint,
  required String? notes,
  required double? latitude,
  required double? longitude,
}) => UtilitySurfaceFixtures.eventFixture(
  id: id,
  meetingPoint: meetingPoint,
  notes: notes,
  latitude: latitude,
  longitude: longitude,
);

String _eventTitleForPayment(Payment payment) =>
    UtilitySurfaceFixtures.eventTitleForPayment(payment);

final _blockedUsers = UtilitySurfaceFixtures.blockedUsers;

Stream<T> _loadingStream<T>() => UtilitySurfaceFixtures.loadingStream<T>();

Stream<T> _errorStream<T>(String message) =>
    UtilitySurfaceFixtures.errorStream<T>(message);

Future<bool> _noopLauncher(Uri uri, {Object? mode}) async {
  return true;
}

void _noop() {}
