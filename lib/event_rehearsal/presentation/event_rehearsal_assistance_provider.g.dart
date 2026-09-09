// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_rehearsal_assistance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A deliberate review fetch, separate from the constantly polling runtime.

@ProviderFor(EventRehearsalAssistance)
final eventRehearsalAssistanceProvider = EventRehearsalAssistanceFamily._();

/// A deliberate review fetch, separate from the constantly polling runtime.
final class EventRehearsalAssistanceProvider
    extends
        $NotifierProvider<
          EventRehearsalAssistance,
          AsyncValue<RehearsalAssistanceReview>
        > {
  /// A deliberate review fetch, separate from the constantly polling runtime.
  EventRehearsalAssistanceProvider._({
    required EventRehearsalAssistanceFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'eventRehearsalAssistanceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventRehearsalAssistanceHash();

  @override
  String toString() {
    return r'eventRehearsalAssistanceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EventRehearsalAssistance create() => EventRehearsalAssistance();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<RehearsalAssistanceReview> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<RehearsalAssistanceReview>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EventRehearsalAssistanceProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventRehearsalAssistanceHash() =>
    r'29ca272c92fc9746cb68edefca0f63e120227a44';

/// A deliberate review fetch, separate from the constantly polling runtime.

final class EventRehearsalAssistanceFamily extends $Family
    with
        $ClassFamilyOverride<
          EventRehearsalAssistance,
          AsyncValue<RehearsalAssistanceReview>,
          AsyncValue<RehearsalAssistanceReview>,
          AsyncValue<RehearsalAssistanceReview>,
          String
        > {
  EventRehearsalAssistanceFamily._()
    : super(
        retry: null,
        name: r'eventRehearsalAssistanceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A deliberate review fetch, separate from the constantly polling runtime.

  EventRehearsalAssistanceProvider call(String sessionId) =>
      EventRehearsalAssistanceProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'eventRehearsalAssistanceProvider';
}

/// A deliberate review fetch, separate from the constantly polling runtime.

abstract class _$EventRehearsalAssistance
    extends $Notifier<AsyncValue<RehearsalAssistanceReview>> {
  late final _$args = ref.$arg as String;
  String get sessionId => _$args;

  AsyncValue<RehearsalAssistanceReview> build(String sessionId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<RehearsalAssistanceReview>,
              AsyncValue<RehearsalAssistanceReview>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<RehearsalAssistanceReview>,
                AsyncValue<RehearsalAssistanceReview>
              >,
              AsyncValue<RehearsalAssistanceReview>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(eventRehearsalAssistanceForAccount)
final eventRehearsalAssistanceForAccountProvider =
    EventRehearsalAssistanceForAccountFamily._();

final class EventRehearsalAssistanceForAccountProvider
    extends
        $FunctionalProvider<
          AsyncValue<RehearsalAssistanceReview>,
          RehearsalAssistanceReview,
          FutureOr<RehearsalAssistanceReview>
        >
    with
        $FutureModifier<RehearsalAssistanceReview>,
        $FutureProvider<RehearsalAssistanceReview> {
  EventRehearsalAssistanceForAccountProvider._({
    required EventRehearsalAssistanceForAccountFamily super.from,
    required (String, {AuthenticatedSession account}) super.argument,
  }) : super(
         retry: _noReviewRetry,
         name: r'eventRehearsalAssistanceForAccountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$eventRehearsalAssistanceForAccountHash();

  @override
  String toString() {
    return r'eventRehearsalAssistanceForAccountProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<RehearsalAssistanceReview> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RehearsalAssistanceReview> create(Ref ref) {
    final argument = this.argument as (String, {AuthenticatedSession account});
    return eventRehearsalAssistanceForAccount(
      ref,
      argument.$1,
      account: argument.account,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EventRehearsalAssistanceForAccountProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventRehearsalAssistanceForAccountHash() =>
    r'8c34745d87993911f2fb481e2f2046e4f7beaefb';

final class EventRehearsalAssistanceForAccountFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<RehearsalAssistanceReview>,
          (String, {AuthenticatedSession account})
        > {
  EventRehearsalAssistanceForAccountFamily._()
    : super(
        retry: _noReviewRetry,
        name: r'eventRehearsalAssistanceForAccountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventRehearsalAssistanceForAccountProvider call(
    String sessionId, {
    required AuthenticatedSession account,
  }) => EventRehearsalAssistanceForAccountProvider._(
    argument: (sessionId, account: account),
    from: this,
  );

  @override
  String toString() => r'eventRehearsalAssistanceForAccountProvider';
}
