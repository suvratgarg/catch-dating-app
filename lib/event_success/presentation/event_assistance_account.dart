import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_assistance_account.g.dart';

/// One uninterrupted authenticated review period. Reusing a UID after
/// sign-out cannot revive an old decision or its cached private information.
final class EventAssistanceAccount {
  EventAssistanceAccount._(this.uid);
  final String uid;
}

@riverpod
AsyncValue<EventAssistanceAccount> eventAssistanceAccount(Ref ref) {
  final auth = ref.watch(uidProvider);
  if (auth.isLoading) return const AsyncLoading();
  if (auth.hasError) return AsyncError(auth.error!, auth.stackTrace!);
  final uid = auth.asData?.value;
  if (uid == null || uid.isEmpty) {
    return AsyncError(
      const SignInRequiredException('review event assistance'),
      StackTrace.current,
    );
  }
  return AsyncData(EventAssistanceAccount._(uid));
}
