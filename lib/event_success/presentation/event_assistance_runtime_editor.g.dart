// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_assistance_runtime_editor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One explicit configure or pause decision. Uncertain saves retain the exact
/// request; saving permission does not report enrollment or provider delivery.

@ProviderFor(EventAssistanceRuntimeEditor)
final eventAssistanceRuntimeEditorProvider =
    EventAssistanceRuntimeEditorFamily._();

/// One explicit configure or pause decision. Uncertain saves retain the exact
/// request; saving permission does not report enrollment or provider delivery.
final class EventAssistanceRuntimeEditorProvider
    extends
        $NotifierProvider<
          EventAssistanceRuntimeEditor,
          AssistanceRuntimeEditorState
        > {
  /// One explicit configure or pause decision. Uncertain saves retain the exact
  /// request; saving permission does not report enrollment or provider delivery.
  EventAssistanceRuntimeEditorProvider._({
    required EventAssistanceRuntimeEditorFamily super.from,
    required AssistanceRuntimeSession super.argument,
  }) : super(
         retry: null,
         name: r'eventAssistanceRuntimeEditorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventAssistanceRuntimeEditorHash();

  @override
  String toString() {
    return r'eventAssistanceRuntimeEditorProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EventAssistanceRuntimeEditor create() => EventAssistanceRuntimeEditor();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AssistanceRuntimeEditorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AssistanceRuntimeEditorState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EventAssistanceRuntimeEditorProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventAssistanceRuntimeEditorHash() =>
    r'4d9aeb119797c6db1d5711598ccd37814bc8848a';

/// One explicit configure or pause decision. Uncertain saves retain the exact
/// request; saving permission does not report enrollment or provider delivery.

final class EventAssistanceRuntimeEditorFamily extends $Family
    with
        $ClassFamilyOverride<
          EventAssistanceRuntimeEditor,
          AssistanceRuntimeEditorState,
          AssistanceRuntimeEditorState,
          AssistanceRuntimeEditorState,
          AssistanceRuntimeSession
        > {
  EventAssistanceRuntimeEditorFamily._()
    : super(
        retry: null,
        name: r'eventAssistanceRuntimeEditorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One explicit configure or pause decision. Uncertain saves retain the exact
  /// request; saving permission does not report enrollment or provider delivery.

  EventAssistanceRuntimeEditorProvider call(AssistanceRuntimeSession review) =>
      EventAssistanceRuntimeEditorProvider._(argument: review, from: this);

  @override
  String toString() => r'eventAssistanceRuntimeEditorProvider';
}

/// One explicit configure or pause decision. Uncertain saves retain the exact
/// request; saving permission does not report enrollment or provider delivery.

abstract class _$EventAssistanceRuntimeEditor
    extends $Notifier<AssistanceRuntimeEditorState> {
  late final _$args = ref.$arg as AssistanceRuntimeSession;
  AssistanceRuntimeSession get review => _$args;

  AssistanceRuntimeEditorState build(AssistanceRuntimeSession review);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AssistanceRuntimeEditorState, AssistanceRuntimeEditorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AssistanceRuntimeEditorState,
                AssistanceRuntimeEditorState
              >,
              AssistanceRuntimeEditorState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
