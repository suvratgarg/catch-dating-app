// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_sheet_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(attendanceSheetViewModel)
final attendanceSheetViewModelProvider = AttendanceSheetViewModelFamily._();

final class AttendanceSheetViewModelProvider
    extends
        $FunctionalProvider<
          AsyncValue<AttendanceSheetViewModel?>,
          AsyncValue<AttendanceSheetViewModel?>,
          AsyncValue<AttendanceSheetViewModel?>
        >
    with $Provider<AsyncValue<AttendanceSheetViewModel?>> {
  AttendanceSheetViewModelProvider._({
    required AttendanceSheetViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'attendanceSheetViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$attendanceSheetViewModelHash();

  @override
  String toString() {
    return r'attendanceSheetViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<AttendanceSheetViewModel?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<AttendanceSheetViewModel?> create(Ref ref) {
    final argument = this.argument as String;
    return attendanceSheetViewModel(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<AttendanceSheetViewModel?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<AttendanceSheetViewModel?>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AttendanceSheetViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$attendanceSheetViewModelHash() =>
    r'86909e722cccae12a32d94a55e468b15d9fb0a2d';

final class AttendanceSheetViewModelFamily extends $Family
    with
        $FunctionalFamilyOverride<
          AsyncValue<AttendanceSheetViewModel?>,
          String
        > {
  AttendanceSheetViewModelFamily._()
    : super(
        retry: null,
        name: r'attendanceSheetViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AttendanceSheetViewModelProvider call(String runId) =>
      AttendanceSheetViewModelProvider._(argument: runId, from: this);

  @override
  String toString() => r'attendanceSheetViewModelProvider';
}
