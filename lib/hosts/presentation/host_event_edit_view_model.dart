import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/events/domain/event_private_access.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_policy_state.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_edit_screen_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

HostEventEditPrivateAccessState buildHostEventEditPrivateAccessState({
  required EventAdmissionPreset admissionPreset,
  required bool loadedPrivateAccess,
  required AsyncValue<EventPrivateAccess?> privateAccess,
}) {
  return HostEventEditPrivateAccessState.from(
    admissionPreset: admissionPreset,
    loadedPrivateAccess: loadedPrivateAccess,
    privateAccess: _catchAsyncState(privateAccess),
  );
}

CatchAsyncState<T> _catchAsyncState<T>(AsyncValue<T> value) {
  return value.when(
    data: CatchAsyncState<T>.data,
    loading: () => const CatchAsyncState.loading(),
    error: (error, stackTrace) => CatchAsyncState<T>.error(error),
  );
}
