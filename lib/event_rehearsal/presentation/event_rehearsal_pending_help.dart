import 'package:catch_dating_app/auth/data/authenticated_session.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal_help_requests.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_rehearsal_pending_help.g.dart';

/// Discovery references only. Each case editor owns its command and retry.
/// A server page may omit a case whose save succeeded without confirmation.
// keepalive: Pending case discovery survives closed sheets until confirmation or account reset.
@Riverpod(keepAlive: true)
class EventRehearsalPendingHelp extends _$EventRehearsalPendingHelp {
  AuthenticatedSession? _account;
  @override
  Set<RehearsalHelpScope> build() {
    final auth = ref.watch(authenticatedSessionProvider);
    _account = auth.isLoading || auth.hasError ? null : auth.asData?.value;
    return const {};
  }

  void retain(RehearsalHelpScope scope, AuthenticatedSession account) {
    if (!identical(_account, account)) return;
    state = Set.unmodifiable({...state, scope});
  }

  void release(RehearsalHelpScope scope, AuthenticatedSession? account) {
    if (!identical(_account, account) || !state.contains(scope)) return;
    state = Set.unmodifiable({...state}..remove(scope));
  }
}
