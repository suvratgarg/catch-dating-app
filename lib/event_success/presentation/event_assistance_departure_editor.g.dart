// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_assistance_departure_editor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One group owns its unresolved departure across review refresh and closure.

@ProviderFor(EventAssistanceDepartureEditor)
final eventAssistanceDepartureEditorProvider =
    EventAssistanceDepartureEditorFamily._();

/// One group owns its unresolved departure across review refresh and closure.
final class EventAssistanceDepartureEditorProvider
    extends
        $NotifierProvider<
          EventAssistanceDepartureEditor,
          EventDepartureEditorState
        > {
  /// One group owns its unresolved departure across review refresh and closure.
  EventAssistanceDepartureEditorProvider._({
    required EventAssistanceDepartureEditorFamily super.from,
    required EventAssistanceGroupScope super.argument,
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
    r'907decf6845a8f652f68112ca0b184b4f6740758';

/// One group owns its unresolved departure across review refresh and closure.

final class EventAssistanceDepartureEditorFamily extends $Family
    with
        $ClassFamilyOverride<
          EventAssistanceDepartureEditor,
          EventDepartureEditorState,
          EventDepartureEditorState,
          EventDepartureEditorState,
          EventAssistanceGroupScope
        > {
  EventAssistanceDepartureEditorFamily._()
    : super(
        retry: null,
        name: r'eventAssistanceDepartureEditorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One group owns its unresolved departure across review refresh and closure.

  EventAssistanceDepartureEditorProvider call(
    EventAssistanceGroupScope scope,
  ) => EventAssistanceDepartureEditorProvider._(argument: scope, from: this);

  @override
  String toString() => r'eventAssistanceDepartureEditorProvider';
}

/// One group owns its unresolved departure across review refresh and closure.

abstract class _$EventAssistanceDepartureEditor
    extends $Notifier<EventDepartureEditorState> {
  late final _$args = ref.$arg as EventAssistanceGroupScope;
  EventAssistanceGroupScope get scope => _$args;

  EventDepartureEditorState build(EventAssistanceGroupScope scope);
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
