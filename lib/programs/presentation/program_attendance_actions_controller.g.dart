// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_attendance_actions_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Attendance-report actions for the reconciliation surface. Widgets go
/// through this controller rather than reaching into repository or share
/// providers directly.

@ProviderFor(ProgramAttendanceActions)
final programAttendanceActionsProvider = ProgramAttendanceActionsProvider._();

/// Attendance-report actions for the reconciliation surface. Widgets go
/// through this controller rather than reaching into repository or share
/// providers directly.
final class ProgramAttendanceActionsProvider
    extends $NotifierProvider<ProgramAttendanceActions, void> {
  /// Attendance-report actions for the reconciliation surface. Widgets go
  /// through this controller rather than reaching into repository or share
  /// providers directly.
  ProgramAttendanceActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'programAttendanceActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$programAttendanceActionsHash();

  @$internal
  @override
  ProgramAttendanceActions create() => ProgramAttendanceActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$programAttendanceActionsHash() =>
    r'29613bbe56ab9313712c5b9d0fffca6a6116fac6';

/// Attendance-report actions for the reconciliation surface. Widgets go
/// through this controller rather than reaching into repository or share
/// providers directly.

abstract class _$ProgramAttendanceActions extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
