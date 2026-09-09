// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_assistance_group_staff_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One verified staff account owns one pending group duty decision across lookup refresh and closure.

@ProviderFor(EventAssistanceGroupStaffController)
final eventAssistanceGroupStaffControllerProvider =
    EventAssistanceGroupStaffControllerFamily._();

/// One verified staff account owns one pending group duty decision across lookup refresh and closure.
final class EventAssistanceGroupStaffControllerProvider
    extends
        $NotifierProvider<
          EventAssistanceGroupStaffController,
          GroupStaffEditorState
        > {
  /// One verified staff account owns one pending group duty decision across lookup refresh and closure.
  EventAssistanceGroupStaffControllerProvider._({
    required EventAssistanceGroupStaffControllerFamily super.from,
    required EventAssistanceGroupStaffTarget super.argument,
  }) : super(
         retry: null,
         name: r'eventAssistanceGroupStaffControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$eventAssistanceGroupStaffControllerHash();

  @override
  String toString() {
    return r'eventAssistanceGroupStaffControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EventAssistanceGroupStaffController create() =>
      EventAssistanceGroupStaffController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GroupStaffEditorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GroupStaffEditorState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EventAssistanceGroupStaffControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventAssistanceGroupStaffControllerHash() =>
    r'd6e8fae32f0581eeefe1262640c86eac212ee795';

/// One verified staff account owns one pending group duty decision across lookup refresh and closure.

final class EventAssistanceGroupStaffControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          EventAssistanceGroupStaffController,
          GroupStaffEditorState,
          GroupStaffEditorState,
          GroupStaffEditorState,
          EventAssistanceGroupStaffTarget
        > {
  EventAssistanceGroupStaffControllerFamily._()
    : super(
        retry: null,
        name: r'eventAssistanceGroupStaffControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One verified staff account owns one pending group duty decision across lookup refresh and closure.

  EventAssistanceGroupStaffControllerProvider call(
    EventAssistanceGroupStaffTarget target,
  ) => EventAssistanceGroupStaffControllerProvider._(
    argument: target,
    from: this,
  );

  @override
  String toString() => r'eventAssistanceGroupStaffControllerProvider';
}

/// One verified staff account owns one pending group duty decision across lookup refresh and closure.

abstract class _$EventAssistanceGroupStaffController
    extends $Notifier<GroupStaffEditorState> {
  late final _$args = ref.$arg as EventAssistanceGroupStaffTarget;
  EventAssistanceGroupStaffTarget get target => _$args;

  GroupStaffEditorState build(EventAssistanceGroupStaffTarget target);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<GroupStaffEditorState, GroupStaffEditorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GroupStaffEditorState, GroupStaffEditorState>,
              GroupStaffEditorState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
