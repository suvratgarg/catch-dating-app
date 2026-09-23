import 'dart:async';

import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'program_projection_lifetime.g.dart';

@riverpod
DateTime Function() programProjectionClock(Ref ref) => DateTime.now;

/// One exact deadline signal shared by reads and modal projections. Null is
/// reserved for organizer managers; staff projections carry a server deadline.
bool isProgramProjectionActive(DateTime? expiresAt, DateTime now) =>
    expiresAt == null || expiresAt.isAfter(now);

@riverpod
bool programProjectionActive(Ref ref, DateTime? expiresAt) {
  if (expiresAt == null) return true;
  final remaining = expiresAt.difference(
    ref.watch(programProjectionClockProvider)(),
  );
  if (remaining <= Duration.zero) return false;
  final timer = Timer(remaining, () => ref.invalidateSelf(asReload: true));
  ref.onDispose(timer.cancel);
  return true;
}

/// Rebuilding this dependency clears old data while a narrower view reloads.
void retainProgramProjection(
  Ref ref,
  DateTime? expiresAt, {
  void Function()? onExpiry,
}) {
  if (!ref.mounted) {
    throw const PermissionException(
      'Program access changed. Refresh this view.',
    );
  }
  final provider = programProjectionActiveProvider(expiresAt);
  if (onExpiry != null) {
    ref.listen(provider, (_, active) {
      if (!active) onExpiry();
    });
  }
  if (!ref.watch(provider)) {
    throw const PermissionException(
      'Program access expired. Refresh this view.',
    );
  }
}
