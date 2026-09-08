import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callables/get_event_assistance_runtime_config_callable_request.g.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_runtime_result.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_runtime_scope.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_runtime_setting.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_assistance_runtime_repository.g.dart';

class EventAssistanceRuntimeRepository {
  const EventAssistanceRuntimeRepository(this._functions);
  final FirebaseFunctions _functions;
  Future<AssistanceRuntimeView> fetch(EventAssistanceRuntimeScope scope) =>
      withBackendErrorContext(
        () async {
          final response = await _functions
              .httpsCallable('getEventAssistanceRuntimeConfig')
              .call<Object?>(
                GetEventAssistanceRuntimeConfigCallableRequest(
                  context: scope.context,
                ).toJson(),
              );
          return AssistanceRuntimeResult.fromCallableData(
            response.data,
            expectedScope: scope,
          ).view;
        },
        context: const BackendErrorContext(
          service: BackendService.functions,
          action: 'load event automation',
          resource: 'eventAssistanceRuntimeConfigs',
        ),
        mapper: mapMissingCallableAsUnavailable,
      );
  Future<AssistanceRuntimeResult> apply(AssistanceRuntimeChange change) =>
      withBackendErrorContext(
        () async {
          final response = await _functions
              .httpsCallable('setEventAssistanceRuntimeConfig')
              .call<Object?>(change.toJson());
          return AssistanceRuntimeResult.fromCallableData(
            response.data,
            expectedScope: change.snapshot.scope,
            expectedChange: change,
          );
        },
        context: const BackendErrorContext(
          service: BackendService.functions,
          action: 'save event automation',
          resource: 'eventAssistanceRuntimeConfigs',
        ),
        mapper: mapMissingCallableAsUnavailable,
      );
}

@riverpod
EventAssistanceRuntimeRepository eventAssistanceRuntimeRepository(Ref ref) =>
    EventAssistanceRuntimeRepository(ref.watch(firebaseFunctionsProvider));
