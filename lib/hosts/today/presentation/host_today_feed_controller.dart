import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/hosts/data/host_attendance_outbox.dart';
import 'package:catch_dating_app/hosts/today/data/host_attention_repository.dart';
import 'package:catch_dating_app/hosts/today/domain/host_attention_item.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'host_today_feed_controller.g.dart';

@immutable
class HostTodayFeedRequest {
  const HostTodayFeedRequest({
    required this.organizerId,
    required this.accountId,
    required this.sessionBoundary,
  });

  final String organizerId;
  final String accountId;
  final DateTime sessionBoundary;

  @override
  bool operator ==(Object other) =>
      other is HostTodayFeedRequest &&
      other.organizerId == organizerId &&
      other.accountId == accountId &&
      other.sessionBoundary == sessionBoundary;

  @override
  int get hashCode => Object.hash(organizerId, accountId, sessionBoundary);
}

enum HostTodayAttentionIssueSource { serverProjection, attendanceOutbox }

@immutable
class HostTodayAttentionIssue {
  const HostTodayAttentionIssue({
    required this.source,
    required this.error,
    required this.stackTrace,
  });

  final HostTodayAttentionIssueSource source;
  final Object error;
  final StackTrace stackTrace;
}

@immutable
class HostTodayFeedData {
  const HostTodayFeedData({
    required this.activeEvents,
    required this.pastEvents,
    this.attentionItems = const <HostAttentionItem>[],
    this.attentionCoverage = const <HostAttentionCoverage>[],
    this.attentionIssues = const <HostTodayAttentionIssue>[],
    this.attentionGeneratedAt,
    this.attentionHorizonEndsAt,
    this.localAttendanceMerged = false,
  });

  final List<Event> activeEvents;
  final List<Event> pastEvents;
  final List<HostAttentionItem> attentionItems;
  final List<HostAttentionCoverage> attentionCoverage;
  final List<HostTodayAttentionIssue> attentionIssues;
  final DateTime? attentionGeneratedAt;
  final DateTime? attentionHorizonEndsAt;
  final bool localAttendanceMerged;

  bool get hasPastEvents => pastEvents.isNotEmpty;
  bool get hasAttentionIssues => attentionIssues.isNotEmpty;
}

@riverpod
class HostTodayFeedController extends _$HostTodayFeedController {
  @override
  Future<HostTodayFeedData> build(HostTodayFeedRequest request) async {
    final eventRepository = ref.watch(eventRepositoryProvider);
    final activePage = await eventRepository.fetchActiveEventsPage(
      organizerId: request.organizerId,
      sessionBoundary: request.sessionBoundary,
    );
    final attentionFuture = _captureOptional(
      () =>
          ref.read(hostAttentionRepositoryProvider).fetch(request.organizerId),
    );
    final attendanceFuture = _captureOptional(
      () => ref
          .read(hostAttendanceOutboxProvider)
          .loadAll(accountId: request.accountId, now: request.sessionBoundary),
    );
    final historyFuture = _captureOptional(
      () => eventRepository.fetchPastEventsPage(
        organizerId: request.organizerId,
        sessionBoundary: request.sessionBoundary,
      ),
    );
    final attention = await attentionFuture;
    final attendance = await attendanceFuture;
    final history = await historyFuture;
    final projection = attention.value;
    final issues = <HostTodayAttentionIssue>[
      if (attention.error case final error?)
        HostTodayAttentionIssue(
          source: HostTodayAttentionIssueSource.serverProjection,
          error: error,
          stackTrace: attention.stackTrace!,
        ),
      if (attendance.error case final error?)
        HostTodayAttentionIssue(
          source: HostTodayAttentionIssueSource.attendanceOutbox,
          error: error,
          stackTrace: attendance.stackTrace!,
        ),
    ];
    final items = <HostAttentionItem>[
      ...?projection?.items,
      if (attendance.value case final outbox?)
        ..._attendanceItems(
          outbox,
          activeEvents: activePage.items,
          accountId: request.accountId,
          now: request.sessionBoundary,
          policyVersion: projection?.policyVersion,
        ),
    ]..sort(_compareAttentionItems);
    return HostTodayFeedData(
      activeEvents: List<Event>.unmodifiable(activePage.items),
      pastEvents: List<Event>.unmodifiable(
        history.value?.items ?? const <Event>[],
      ),
      attentionItems: List<HostAttentionItem>.unmodifiable(items),
      attentionCoverage:
          projection?.coverage ?? const <HostAttentionCoverage>[],
      attentionIssues: List<HostTodayAttentionIssue>.unmodifiable(issues),
      attentionGeneratedAt: projection?.generatedAt,
      attentionHorizonEndsAt: projection?.horizonEndsAt,
      localAttendanceMerged: attendance.value != null,
    );
  }

  void retry() {
    ref.invalidateSelf();
  }
}

Future<_OptionalLoad<T>> _captureOptional<T>(Future<T> Function() load) async {
  try {
    return _OptionalLoad<T>.data(await load());
  } on Object catch (error, stackTrace) {
    return _OptionalLoad<T>.error(error, stackTrace);
  }
}

@immutable
class _OptionalLoad<T> {
  const _OptionalLoad._({this.value, this.error, this.stackTrace});

  const _OptionalLoad.data(T value) : this._(value: value);

  const _OptionalLoad.error(Object error, StackTrace stackTrace)
    : this._(error: error, stackTrace: stackTrace);

  final T? value;
  final Object? error;
  final StackTrace? stackTrace;
}

Iterable<HostAttentionItem> _attendanceItems(
  HostAttendanceOutboxSummary outbox, {
  required List<Event> activeEvents,
  required String accountId,
  required DateTime now,
  required int? policyVersion,
}) sync* {
  final eventsById = <String, Event>{
    for (final event in activeEvents) event.id: event,
  };
  for (final entry in outbox.entries) {
    final needsReview = entry.status == HostAttendanceOutboxStatus.needsReview;
    final reviewAt = entry.createdAt.add(HostAttendanceOutbox.reviewAfter);
    final dueAt = needsReview ? now : reviewAt;
    yield HostAttentionItem(
      id: 'local-attendance-${entry.clientOperationId}',
      kind: HostAttentionKind.attendanceSync,
      scope: HostAttentionScope.event,
      sourceOwner: HostAttentionSourceOwner.hostAttendanceOutbox,
      sourceId: entry.clientOperationId,
      sourceRevision: [
        entry.expectedRevision,
        entry.desiredCheckedIn,
        entry.status.name,
        entry.lastErrorCode ?? '',
      ].join(':'),
      eventId: entry.eventId,
      status: HostAttentionStatus.open,
      consequence: HostAttentionConsequence.requiresReconciliation,
      blocking: false,
      urgency: needsReview
          ? HostAttentionUrgency.immediate
          : HostAttentionUrgency.upcoming,
      destination: HostAttentionDestination(
        route: HostAttentionDestinationRoute.hostEventManage,
        section: 'guests',
        eventId: entry.eventId,
      ),
      context: HostAttentionContext(
        eventName: eventsById[entry.eventId]?.title,
        count: 1,
        errorCode: entry.lastErrorCode,
      ),
      dedupeKey: 'attendanceSync:${entry.clientOperationId}',
      policyVersion: policyVersion,
      resolutionVersion: 1,
      assignedHostUid: accountId,
      openedAt: entry.createdAt,
      dueAt: dueAt,
      expiresAt: entry.createdAt.add(HostAttendanceOutbox.deleteAfter),
    );
  }
}

int _compareAttentionItems(HostAttentionItem left, HostAttentionItem right) {
  final urgency = left.urgency.index.compareTo(right.urgency.index);
  if (urgency != 0) return urgency;
  final blocking = (right.blocking ? 1 : 0).compareTo(left.blocking ? 1 : 0);
  if (blocking != 0) return blocking;
  final dueAt = left.dueAt.compareTo(right.dueAt);
  if (dueAt != 0) return dueAt;
  return left.id.compareTo(right.id);
}
