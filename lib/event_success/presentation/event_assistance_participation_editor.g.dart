// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_assistance_participation_editor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EventAssistanceParticipationEditor)
final eventAssistanceParticipationEditorProvider =
    EventAssistanceParticipationEditorFamily._();

final class EventAssistanceParticipationEditorProvider
    extends
        $NotifierProvider<
          EventAssistanceParticipationEditor,
          EventParticipationEditorState
        > {
  EventAssistanceParticipationEditorProvider._({
    required EventAssistanceParticipationEditorFamily super.from,
    required EventParticipationSession super.argument,
  }) : super(
         retry: null,
         name: r'eventAssistanceParticipationEditorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$eventAssistanceParticipationEditorHash();

  @override
  String toString() {
    return r'eventAssistanceParticipationEditorProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EventAssistanceParticipationEditor create() =>
      EventAssistanceParticipationEditor();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EventParticipationEditorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EventParticipationEditorState>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EventAssistanceParticipationEditorProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventAssistanceParticipationEditorHash() =>
    r'f52464471b2911e7450b987cf8b19a797702d2dd';

final class EventAssistanceParticipationEditorFamily extends $Family
    with
        $ClassFamilyOverride<
          EventAssistanceParticipationEditor,
          EventParticipationEditorState,
          EventParticipationEditorState,
          EventParticipationEditorState,
          EventParticipationSession
        > {
  EventAssistanceParticipationEditorFamily._()
    : super(
        retry: null,
        name: r'eventAssistanceParticipationEditorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventAssistanceParticipationEditorProvider call(
    EventParticipationSession session,
  ) => EventAssistanceParticipationEditorProvider._(
    argument: session,
    from: this,
  );

  @override
  String toString() => r'eventAssistanceParticipationEditorProvider';
}

abstract class _$EventAssistanceParticipationEditor
    extends $Notifier<EventParticipationEditorState> {
  late final _$args = ref.$arg as EventParticipationSession;
  EventParticipationSession get session => _$args;

  EventParticipationEditorState build(EventParticipationSession session);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              EventParticipationEditorState,
              EventParticipationEditorState
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                EventParticipationEditorState,
                EventParticipationEditorState
              >,
              EventParticipationEditorState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
