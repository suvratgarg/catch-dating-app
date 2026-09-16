// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_assistance_participation_editor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One guest owns one pending participation decision across review refresh and closure.

@ProviderFor(EventAssistanceParticipationEditor)
final eventAssistanceParticipationEditorProvider =
    EventAssistanceParticipationEditorFamily._();

/// One guest owns one pending participation decision across review refresh and closure.
final class EventAssistanceParticipationEditorProvider
    extends
        $NotifierProvider<
          EventAssistanceParticipationEditor,
          EventParticipationEditorState
        > {
  /// One guest owns one pending participation decision across review refresh and closure.
  EventAssistanceParticipationEditorProvider._({
    required EventAssistanceParticipationEditorFamily super.from,
    required EventAssistanceGuestScope super.argument,
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
    r'200eb7a00a98b19be98d10c41daebae094b865f9';

/// One guest owns one pending participation decision across review refresh and closure.

final class EventAssistanceParticipationEditorFamily extends $Family
    with
        $ClassFamilyOverride<
          EventAssistanceParticipationEditor,
          EventParticipationEditorState,
          EventParticipationEditorState,
          EventParticipationEditorState,
          EventAssistanceGuestScope
        > {
  EventAssistanceParticipationEditorFamily._()
    : super(
        retry: null,
        name: r'eventAssistanceParticipationEditorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One guest owns one pending participation decision across review refresh and closure.

  EventAssistanceParticipationEditorProvider call(
    EventAssistanceGuestScope scope,
  ) =>
      EventAssistanceParticipationEditorProvider._(argument: scope, from: this);

  @override
  String toString() => r'eventAssistanceParticipationEditorProvider';
}

/// One guest owns one pending participation decision across review refresh and closure.

abstract class _$EventAssistanceParticipationEditor
    extends $Notifier<EventParticipationEditorState> {
  late final _$args = ref.$arg as EventAssistanceGuestScope;
  EventAssistanceGuestScope get scope => _$args;

  EventParticipationEditorState build(EventAssistanceGuestScope scope);
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
