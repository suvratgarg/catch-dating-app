import 'package:catch_dating_app/auth/data/authenticated_session.dart';
import 'package:catch_dating_app/event_success/data/event_participant_context_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_participant_context.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'event_participant_context_provider.g.dart';

final class EventParticipantContextReview {
  EventParticipantContextReview._(this.account, this.view);
  final AuthenticatedSession account;
  final EventParticipantContext view;
  bool _current = true;
  bool get isCurrent => _current;
}

/// Account changes and explicit refresh hide prior identity, including same-UID re-entry.
@riverpod
class EventParticipantContextReader extends _$EventParticipantContextReader {
  @override
  AsyncValue<EventParticipantContextReview> build(String eventId) {
    final auth = ref.watch(authenticatedSessionProvider);
    if (auth.isLoading) {
      return const AsyncLoading();
    }
    if (auth.hasError) {
      return AsyncError(auth.error!, auth.stackTrace!);
    }
    final page = ref.watch(
      eventParticipantContextForAccountProvider(
        eventId,
        account: auth.requireValue,
      ),
    );
    if (page.isLoading) {
      return const AsyncLoading();
    }
    if (page.hasError) {
      return AsyncError(page.error!, page.stackTrace!);
    }
    return page;
  }

  void reload() {
    final auth = ref.read(authenticatedSessionProvider);
    if (auth.isLoading || auth.hasError || auth.asData == null) {
      return;
    }
    ref.invalidate(
      eventParticipantContextForAccountProvider(
        eventId,
        account: auth.requireValue,
      ),
    );
  }
}

@Riverpod(retry: _noRetry)
Future<EventParticipantContextReview> eventParticipantContextForAccount(
  Ref ref,
  String eventId, {
  required AuthenticatedSession account,
}) async {
  ref.watch(authenticatedSessionProvider);
  _requireAccount(ref, account);
  final view = await ref
      .watch(eventParticipantContextRepositoryProvider)
      .fetch(eventId: eventId, subjectUid: account.uid);
  _requireAccount(ref, account);
  if (view.eventId != eventId || view.subjectUid != account.uid) {
    throw const FormatException(
      'Event identity belongs to another participant.',
    );
  }
  final review = EventParticipantContextReview._(account, view);
  ref.onDispose(() => review._current = false);
  return review;
}

void _requireAccount(Ref ref, AuthenticatedSession account) {
  if (!ref.mounted) {
    throw const SignInRequiredException('review event identity');
  }
  final auth = ref.read(authenticatedSessionProvider);
  if (auth.isLoading ||
      auth.hasError ||
      !identical(auth.asData?.value, account)) {
    throw const SignInRequiredException('review event identity');
  }
}

Duration? _noRetry(int count, Object error) => null;
