// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_assistance_case_editor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One reviewed case decision. No implicit default, changed retry, or local
/// optimistic settlement; the response always supplies the current case state.

@ProviderFor(EventAssistanceCaseEditor)
final eventAssistanceCaseEditorProvider = EventAssistanceCaseEditorFamily._();

/// One reviewed case decision. No implicit default, changed retry, or local
/// optimistic settlement; the response always supplies the current case state.
final class EventAssistanceCaseEditorProvider
    extends
        $NotifierProvider<
          EventAssistanceCaseEditor,
          AssistanceCaseEditorState
        > {
  /// One reviewed case decision. No implicit default, changed retry, or local
  /// optimistic settlement; the response always supplies the current case state.
  EventAssistanceCaseEditorProvider._({
    required EventAssistanceCaseEditorFamily super.from,
    required EventAssistanceCaseReview super.argument,
  }) : super(
         retry: null,
         name: r'eventAssistanceCaseEditorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventAssistanceCaseEditorHash();

  @override
  String toString() {
    return r'eventAssistanceCaseEditorProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EventAssistanceCaseEditor create() => EventAssistanceCaseEditor();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AssistanceCaseEditorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AssistanceCaseEditorState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EventAssistanceCaseEditorProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventAssistanceCaseEditorHash() =>
    r'1660792e75dbeefc54c5c29c6b09661248a7f3c0';

/// One reviewed case decision. No implicit default, changed retry, or local
/// optimistic settlement; the response always supplies the current case state.

final class EventAssistanceCaseEditorFamily extends $Family
    with
        $ClassFamilyOverride<
          EventAssistanceCaseEditor,
          AssistanceCaseEditorState,
          AssistanceCaseEditorState,
          AssistanceCaseEditorState,
          EventAssistanceCaseReview
        > {
  EventAssistanceCaseEditorFamily._()
    : super(
        retry: null,
        name: r'eventAssistanceCaseEditorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One reviewed case decision. No implicit default, changed retry, or local
  /// optimistic settlement; the response always supplies the current case state.

  EventAssistanceCaseEditorProvider call(EventAssistanceCaseReview review) =>
      EventAssistanceCaseEditorProvider._(argument: review, from: this);

  @override
  String toString() => r'eventAssistanceCaseEditorProvider';
}

/// One reviewed case decision. No implicit default, changed retry, or local
/// optimistic settlement; the response always supplies the current case state.

abstract class _$EventAssistanceCaseEditor
    extends $Notifier<AssistanceCaseEditorState> {
  late final _$args = ref.$arg as EventAssistanceCaseReview;
  EventAssistanceCaseReview get review => _$args;

  AssistanceCaseEditorState build(EventAssistanceCaseReview review);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AssistanceCaseEditorState, AssistanceCaseEditorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AssistanceCaseEditorState, AssistanceCaseEditorState>,
              AssistanceCaseEditorState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
