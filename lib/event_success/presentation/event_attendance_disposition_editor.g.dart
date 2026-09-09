// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_attendance_disposition_editor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One reviewed attendance decision. No implicit default, changed retry, or local
/// optimistic settlement; the response always supplies the current closeout state.

@ProviderFor(EventAttendanceDispositionEditor)
final eventAttendanceDispositionEditorProvider =
    EventAttendanceDispositionEditorFamily._();

/// One reviewed attendance decision. No implicit default, changed retry, or local
/// optimistic settlement; the response always supplies the current closeout state.
final class EventAttendanceDispositionEditorProvider
    extends
        $NotifierProvider<
          EventAttendanceDispositionEditor,
          AttendanceDispositionEditorState
        > {
  /// One reviewed attendance decision. No implicit default, changed retry, or local
  /// optimistic settlement; the response always supplies the current closeout state.
  EventAttendanceDispositionEditorProvider._({
    required EventAttendanceDispositionEditorFamily super.from,
    required EventAttendanceDispositionReview super.argument,
  }) : super(
         retry: null,
         name: r'eventAttendanceDispositionEditorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventAttendanceDispositionEditorHash();

  @override
  String toString() {
    return r'eventAttendanceDispositionEditorProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EventAttendanceDispositionEditor create() =>
      EventAttendanceDispositionEditor();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AttendanceDispositionEditorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AttendanceDispositionEditorState>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EventAttendanceDispositionEditorProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventAttendanceDispositionEditorHash() =>
    r'5ba89ec50b8766e0c082d2749923d37035010fc4';

/// One reviewed attendance decision. No implicit default, changed retry, or local
/// optimistic settlement; the response always supplies the current closeout state.

final class EventAttendanceDispositionEditorFamily extends $Family
    with
        $ClassFamilyOverride<
          EventAttendanceDispositionEditor,
          AttendanceDispositionEditorState,
          AttendanceDispositionEditorState,
          AttendanceDispositionEditorState,
          EventAttendanceDispositionReview
        > {
  EventAttendanceDispositionEditorFamily._()
    : super(
        retry: null,
        name: r'eventAttendanceDispositionEditorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One reviewed attendance decision. No implicit default, changed retry, or local
  /// optimistic settlement; the response always supplies the current closeout state.

  EventAttendanceDispositionEditorProvider call(
    EventAttendanceDispositionReview review,
  ) => EventAttendanceDispositionEditorProvider._(argument: review, from: this);

  @override
  String toString() => r'eventAttendanceDispositionEditorProvider';
}

/// One reviewed attendance decision. No implicit default, changed retry, or local
/// optimistic settlement; the response always supplies the current closeout state.

abstract class _$EventAttendanceDispositionEditor
    extends $Notifier<AttendanceDispositionEditorState> {
  late final _$args = ref.$arg as EventAttendanceDispositionReview;
  EventAttendanceDispositionReview get review => _$args;

  AttendanceDispositionEditorState build(
    EventAttendanceDispositionReview review,
  );
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AttendanceDispositionEditorState,
              AttendanceDispositionEditorState
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AttendanceDispositionEditorState,
                AttendanceDispositionEditorState
              >,
              AttendanceDispositionEditorState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
