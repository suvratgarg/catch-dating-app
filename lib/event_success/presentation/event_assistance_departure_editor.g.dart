// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_assistance_departure_editor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EventAssistanceDepartureEditor)
final eventAssistanceDepartureEditorProvider =
    EventAssistanceDepartureEditorFamily._();

final class EventAssistanceDepartureEditorProvider
    extends
        $NotifierProvider<
          EventAssistanceDepartureEditor,
          EventDepartureEditorState
        > {
  EventAssistanceDepartureEditorProvider._({
    required EventAssistanceDepartureEditorFamily super.from,
    required EventDepartureSession super.argument,
  }) : super(
         retry: null,
         name: r'eventAssistanceDepartureEditorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventAssistanceDepartureEditorHash();

  @override
  String toString() {
    return r'eventAssistanceDepartureEditorProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EventAssistanceDepartureEditor create() => EventAssistanceDepartureEditor();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EventDepartureEditorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EventDepartureEditorState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EventAssistanceDepartureEditorProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventAssistanceDepartureEditorHash() =>
    r'f5c713d9aaa809c975688d73467eac16d2adbf8b';

final class EventAssistanceDepartureEditorFamily extends $Family
    with
        $ClassFamilyOverride<
          EventAssistanceDepartureEditor,
          EventDepartureEditorState,
          EventDepartureEditorState,
          EventDepartureEditorState,
          EventDepartureSession
        > {
  EventAssistanceDepartureEditorFamily._()
    : super(
        retry: null,
        name: r'eventAssistanceDepartureEditorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventAssistanceDepartureEditorProvider call(EventDepartureSession session) =>
      EventAssistanceDepartureEditorProvider._(argument: session, from: this);

  @override
  String toString() => r'eventAssistanceDepartureEditorProvider';
}

abstract class _$EventAssistanceDepartureEditor
    extends $Notifier<EventDepartureEditorState> {
  late final _$args = ref.$arg as EventDepartureSession;
  EventDepartureSession get session => _$args;

  EventDepartureEditorState build(EventDepartureSession session);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<EventDepartureEditorState, EventDepartureEditorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EventDepartureEditorState, EventDepartureEditorState>,
              EventDepartureEditorState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
