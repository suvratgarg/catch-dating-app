// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_rehearsal_assistance_editor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One reviewed practice command. Applied means its action receipt was verified;
/// it never promotes an accepted send or reported intention into delivery/arrival.

@ProviderFor(EventRehearsalAssistanceEditor)
final eventRehearsalAssistanceEditorProvider =
    EventRehearsalAssistanceEditorFamily._();

/// One reviewed practice command. Applied means its action receipt was verified;
/// it never promotes an accepted send or reported intention into delivery/arrival.
final class EventRehearsalAssistanceEditorProvider
    extends
        $NotifierProvider<
          EventRehearsalAssistanceEditor,
          RehearsalAssistanceEditorState
        > {
  /// One reviewed practice command. Applied means its action receipt was verified;
  /// it never promotes an accepted send or reported intention into delivery/arrival.
  EventRehearsalAssistanceEditorProvider._({
    required EventRehearsalAssistanceEditorFamily super.from,
    required RehearsalAssistanceReview super.argument,
  }) : super(
         retry: null,
         name: r'eventRehearsalAssistanceEditorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventRehearsalAssistanceEditorHash();

  @override
  String toString() {
    return r'eventRehearsalAssistanceEditorProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EventRehearsalAssistanceEditor create() => EventRehearsalAssistanceEditor();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RehearsalAssistanceEditorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RehearsalAssistanceEditorState>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EventRehearsalAssistanceEditorProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventRehearsalAssistanceEditorHash() =>
    r'0a53e4e449dcd852faf5ffc23e7316a7de530e66';

/// One reviewed practice command. Applied means its action receipt was verified;
/// it never promotes an accepted send or reported intention into delivery/arrival.

final class EventRehearsalAssistanceEditorFamily extends $Family
    with
        $ClassFamilyOverride<
          EventRehearsalAssistanceEditor,
          RehearsalAssistanceEditorState,
          RehearsalAssistanceEditorState,
          RehearsalAssistanceEditorState,
          RehearsalAssistanceReview
        > {
  EventRehearsalAssistanceEditorFamily._()
    : super(
        retry: null,
        name: r'eventRehearsalAssistanceEditorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One reviewed practice command. Applied means its action receipt was verified;
  /// it never promotes an accepted send or reported intention into delivery/arrival.

  EventRehearsalAssistanceEditorProvider call(
    RehearsalAssistanceReview review,
  ) => EventRehearsalAssistanceEditorProvider._(argument: review, from: this);

  @override
  String toString() => r'eventRehearsalAssistanceEditorProvider';
}

/// One reviewed practice command. Applied means its action receipt was verified;
/// it never promotes an accepted send or reported intention into delivery/arrival.

abstract class _$EventRehearsalAssistanceEditor
    extends $Notifier<RehearsalAssistanceEditorState> {
  late final _$args = ref.$arg as RehearsalAssistanceReview;
  RehearsalAssistanceReview get review => _$args;

  RehearsalAssistanceEditorState build(RehearsalAssistanceReview review);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              RehearsalAssistanceEditorState,
              RehearsalAssistanceEditorState
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                RehearsalAssistanceEditorState,
                RehearsalAssistanceEditorState
              >,
              RehearsalAssistanceEditorState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
