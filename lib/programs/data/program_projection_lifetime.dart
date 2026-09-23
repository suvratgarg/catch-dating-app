import 'dart:async';

import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:flutter/widgets.dart' show AppLifecycleListener;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'program_projection_lifetime.g.dart';

@riverpod
DateTime Function() programProjectionClock(Ref ref) => DateTime.now;

/// One exact deadline signal shared by reads and modal projections. Null is
/// reserved for organizer managers; staff projections carry a server deadline.
bool isProgramProjectionActive(DateTime? expiresAt, DateTime now) =>
    expiresAt == null || expiresAt.isAfter(now);

/// Server authority and offline freshness independently bound a visible view.
DateTime? programProjectionDeadline(
  DateTime? accessExpiresAt,
  DateTime? snapshotExpiresAt,
) {
  if (accessExpiresAt == null) return snapshotExpiresAt;
  if (snapshotExpiresAt == null) return accessExpiresAt;
  return accessExpiresAt.isBefore(snapshotExpiresAt)
      ? accessExpiresAt
      : snapshotExpiresAt;
}

@riverpod
bool programProjectionActive(Ref ref, DateTime? expiresAt) {
  if (expiresAt == null) return true;
  // Recheck wall time on resume even if a suspended timer has not fired yet.
  final lifecycle = AppLifecycleListener(
    onResume: () => ref.invalidateSelf(asReload: true),
  );
  ref.onDispose(lifecycle.dispose);
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
