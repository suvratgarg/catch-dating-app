// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_assistance_late_join_setting_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EventAssistanceLateJoinSetting)
final eventAssistanceLateJoinSettingProvider =
    EventAssistanceLateJoinSettingFamily._();

final class EventAssistanceLateJoinSettingProvider
    extends
        $NotifierProvider<
          EventAssistanceLateJoinSetting,
          AsyncValue<LateJoinSettingSession>
        > {
  EventAssistanceLateJoinSettingProvider._({
    required EventAssistanceLateJoinSettingFamily super.from,
    required EventAssistanceGroupScope super.argument,
  }) : super(
         retry: null,
         name: r'eventAssistanceLateJoinSettingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventAssistanceLateJoinSettingHash();

  @override
  String toString() {
    return r'eventAssistanceLateJoinSettingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EventAssistanceLateJoinSetting create() => EventAssistanceLateJoinSetting();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<LateJoinSettingSession> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<LateJoinSettingSession>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EventAssistanceLateJoinSettingProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventAssistanceLateJoinSettingHash() =>
    r'08e993a3abdf3e1fa2da64c119854b0199f485fe';

final class EventAssistanceLateJoinSettingFamily extends $Family
    with
        $ClassFamilyOverride<
          EventAssistanceLateJoinSetting,
          AsyncValue<LateJoinSettingSession>,
          AsyncValue<LateJoinSettingSession>,
          AsyncValue<LateJoinSettingSession>,
          EventAssistanceGroupScope
        > {
  EventAssistanceLateJoinSettingFamily._()
    : super(
        retry: null,
        name: r'eventAssistanceLateJoinSettingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventAssistanceLateJoinSettingProvider call(
    EventAssistanceGroupScope query,
  ) => EventAssistanceLateJoinSettingProvider._(argument: query, from: this);

  @override
  String toString() => r'eventAssistanceLateJoinSettingProvider';
}

abstract class _$EventAssistanceLateJoinSetting
    extends $Notifier<AsyncValue<LateJoinSettingSession>> {
  late final _$args = ref.$arg as EventAssistanceGroupScope;
  EventAssistanceGroupScope get query => _$args;

  AsyncValue<LateJoinSettingSession> build(EventAssistanceGroupScope query);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<LateJoinSettingSession>,
              AsyncValue<LateJoinSettingSession>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<LateJoinSettingSession>,
                AsyncValue<LateJoinSettingSession>
              >,
              AsyncValue<LateJoinSettingSession>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(eventAssistanceLateJoinSettingForAccount)
final eventAssistanceLateJoinSettingForAccountProvider =
    EventAssistanceLateJoinSettingForAccountFamily._();

final class EventAssistanceLateJoinSettingForAccountProvider
    extends
        $FunctionalProvider<
          AsyncValue<LateJoinSettingSession>,
          LateJoinSettingSession,
          FutureOr<LateJoinSettingSession>
        >
    with
        $FutureModifier<LateJoinSettingSession>,
        $FutureProvider<LateJoinSettingSession> {
  EventAssistanceLateJoinSettingForAccountProvider._({
    required EventAssistanceLateJoinSettingForAccountFamily super.from,
    required (EventAssistanceGroupScope, {EventAssistanceAccount account})
    super.argument,
  }) : super(
         retry: _noSettingReadRetry,
         name: r'eventAssistanceLateJoinSettingForAccountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$eventAssistanceLateJoinSettingForAccountHash();

  @override
  String toString() {
    return r'eventAssistanceLateJoinSettingForAccountProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<LateJoinSettingSession> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LateJoinSettingSession> create(Ref ref) {
    final argument =
        this.argument
            as (EventAssistanceGroupScope, {EventAssistanceAccount account});
    return eventAssistanceLateJoinSettingForAccount(
      ref,
      argument.$1,
      account: argument.account,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EventAssistanceLateJoinSettingForAccountProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventAssistanceLateJoinSettingForAccountHash() =>
    r'92bed2b4eaa90a3435306aa637695300803fd2d0';

final class EventAssistanceLateJoinSettingForAccountFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<LateJoinSettingSession>,
          (EventAssistanceGroupScope, {EventAssistanceAccount account})
        > {
  EventAssistanceLateJoinSettingForAccountFamily._()
    : super(
        retry: _noSettingReadRetry,
        name: r'eventAssistanceLateJoinSettingForAccountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventAssistanceLateJoinSettingForAccountProvider call(
    EventAssistanceGroupScope query, {
    required EventAssistanceAccount account,
  }) => EventAssistanceLateJoinSettingForAccountProvider._(
    argument: (query, account: account),
    from: this,
  );

  @override
  String toString() => r'eventAssistanceLateJoinSettingForAccountProvider';
}
