// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_assistance_late_join_setting_editor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One reviewed preference. Suggestions remain unselected until an explicit
/// host choice; uncertain saves retain the exact request and review basis.

@ProviderFor(EventAssistanceLateJoinSettingEditor)
final eventAssistanceLateJoinSettingEditorProvider =
    EventAssistanceLateJoinSettingEditorFamily._();

/// One reviewed preference. Suggestions remain unselected until an explicit
/// host choice; uncertain saves retain the exact request and review basis.
final class EventAssistanceLateJoinSettingEditorProvider
    extends
        $NotifierProvider<
          EventAssistanceLateJoinSettingEditor,
          LateJoinSettingEditorState
        > {
  /// One reviewed preference. Suggestions remain unselected until an explicit
  /// host choice; uncertain saves retain the exact request and review basis.
  EventAssistanceLateJoinSettingEditorProvider._({
    required EventAssistanceLateJoinSettingEditorFamily super.from,
    required LateJoinSettingSession super.argument,
  }) : super(
         retry: null,
         name: r'eventAssistanceLateJoinSettingEditorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$eventAssistanceLateJoinSettingEditorHash();

  @override
  String toString() {
    return r'eventAssistanceLateJoinSettingEditorProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EventAssistanceLateJoinSettingEditor create() =>
      EventAssistanceLateJoinSettingEditor();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LateJoinSettingEditorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LateJoinSettingEditorState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EventAssistanceLateJoinSettingEditorProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventAssistanceLateJoinSettingEditorHash() =>
    r'fc4fe17eb0d8f4cc34c039aaca9c3e07121d7c4b';

/// One reviewed preference. Suggestions remain unselected until an explicit
/// host choice; uncertain saves retain the exact request and review basis.

final class EventAssistanceLateJoinSettingEditorFamily extends $Family
    with
        $ClassFamilyOverride<
          EventAssistanceLateJoinSettingEditor,
          LateJoinSettingEditorState,
          LateJoinSettingEditorState,
          LateJoinSettingEditorState,
          LateJoinSettingSession
        > {
  EventAssistanceLateJoinSettingEditorFamily._()
    : super(
        retry: null,
        name: r'eventAssistanceLateJoinSettingEditorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One reviewed preference. Suggestions remain unselected until an explicit
  /// host choice; uncertain saves retain the exact request and review basis.

  EventAssistanceLateJoinSettingEditorProvider call(
    LateJoinSettingSession review,
  ) => EventAssistanceLateJoinSettingEditorProvider._(
    argument: review,
    from: this,
  );

  @override
  String toString() => r'eventAssistanceLateJoinSettingEditorProvider';
}

/// One reviewed preference. Suggestions remain unselected until an explicit
/// host choice; uncertain saves retain the exact request and review basis.

abstract class _$EventAssistanceLateJoinSettingEditor
    extends $Notifier<LateJoinSettingEditorState> {
  late final _$args = ref.$arg as LateJoinSettingSession;
  LateJoinSettingSession get review => _$args;

  LateJoinSettingEditorState build(LateJoinSettingSession review);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<LateJoinSettingEditorState, LateJoinSettingEditorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                LateJoinSettingEditorState,
                LateJoinSettingEditorState
              >,
              LateJoinSettingEditorState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
