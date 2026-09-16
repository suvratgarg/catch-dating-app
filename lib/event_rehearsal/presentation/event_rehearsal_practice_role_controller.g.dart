// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_rehearsal_practice_role_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A role selection belongs to one signed-in Host and one synthetic run.
/// It supplies query identity, never authority or a server-global acting role.

@ProviderFor(EventRehearsalPracticeRoleController)
final eventRehearsalPracticeRoleControllerProvider =
    EventRehearsalPracticeRoleControllerFamily._();

/// A role selection belongs to one signed-in Host and one synthetic run.
/// It supplies query identity, never authority or a server-global acting role.
final class EventRehearsalPracticeRoleControllerProvider
    extends $NotifierProvider<EventRehearsalPracticeRoleController, String?> {
  /// A role selection belongs to one signed-in Host and one synthetic run.
  /// It supplies query identity, never authority or a server-global acting role.
  EventRehearsalPracticeRoleControllerProvider._({
    required EventRehearsalPracticeRoleControllerFamily super.from,
    required RehearsalPracticeRoleScope super.argument,
  }) : super(
         retry: null,
         name: r'eventRehearsalPracticeRoleControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$eventRehearsalPracticeRoleControllerHash();

  @override
  String toString() {
    return r'eventRehearsalPracticeRoleControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EventRehearsalPracticeRoleController create() =>
      EventRehearsalPracticeRoleController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EventRehearsalPracticeRoleControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventRehearsalPracticeRoleControllerHash() =>
    r'6c0043c52173a363ef513b94bcf53f3a3ac65e48';

/// A role selection belongs to one signed-in Host and one synthetic run.
/// It supplies query identity, never authority or a server-global acting role.

final class EventRehearsalPracticeRoleControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          EventRehearsalPracticeRoleController,
          String?,
          String?,
          String?,
          RehearsalPracticeRoleScope
        > {
  EventRehearsalPracticeRoleControllerFamily._()
    : super(
        retry: null,
        name: r'eventRehearsalPracticeRoleControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A role selection belongs to one signed-in Host and one synthetic run.
  /// It supplies query identity, never authority or a server-global acting role.

  EventRehearsalPracticeRoleControllerProvider call(
    RehearsalPracticeRoleScope scope,
  ) => EventRehearsalPracticeRoleControllerProvider._(
    argument: scope,
    from: this,
  );

  @override
  String toString() => r'eventRehearsalPracticeRoleControllerProvider';
}

/// A role selection belongs to one signed-in Host and one synthetic run.
/// It supplies query identity, never authority or a server-global acting role.

abstract class _$EventRehearsalPracticeRoleController
    extends $Notifier<String?> {
  late final _$args = ref.$arg as RehearsalPracticeRoleScope;
  RehearsalPracticeRoleScope get scope => _$args;

  String? build(RehearsalPracticeRoleScope scope);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
