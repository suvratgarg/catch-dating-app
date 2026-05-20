import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'suvbot_repository.g.dart';

const suvbotUid = 'suvbot';

bool isSuvbotConversation({required String matchId, String? otherUid}) {
  return otherUid == suvbotUid || matchId.startsWith('${suvbotUid}_');
}

final class SuvbotActionItem {
  const SuvbotActionItem({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    this.destructive = false,
    this.requiresText = false,
  });

  factory SuvbotActionItem.fromCallableData(Object? data) {
    if (data case final Map<Object?, Object?> map) {
      return SuvbotActionItem(
        id: _stringField(map, 'id'),
        label: _stringField(map, 'label'),
        description: _stringField(map, 'description'),
        icon: _stringField(map, 'icon'),
        destructive: map['destructive'] == true,
        requiresText: map['requiresText'] == true,
      );
    }

    throw StateError('Suvbot action response was malformed.');
  }

  static List<SuvbotActionItem> listFromCallableData(Object? data) {
    if (data case final Map<Object?, Object?> map) {
      final actions = map['actions'];
      if (actions is List<Object?>) {
        return actions
            .map(SuvbotActionItem.fromCallableData)
            .toList(growable: false);
      }
    }

    return const [];
  }

  final String id;
  final String label;
  final String description;
  final String icon;
  final bool destructive;
  final bool requiresText;
}

class SuvbotRepository {
  const SuvbotRepository(this._functions);

  final FirebaseFunctions _functions;

  Future<List<SuvbotActionItem>> fetchActions() => withBackendErrorContext(
    () async {
      final result = await _functions
          .httpsCallable('listSuvbotDemoActions')
          .call<Object?>();
      return SuvbotActionItem.listFromCallableData(result.data);
    },
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'load Suvbot controls',
      resource: 'demoOpsRequests',
    ),
  );

  Future<void> requestAction({required String actionId, String? text}) =>
      withBackendErrorContext(
        () {
          final payload = <String, Object?>{'action': actionId};
          if (text != null) payload['text'] = text;
          return _functions
              .httpsCallable('requestSuvbotDemoOperation')
              .call<Object?>(payload);
        },
        context: const BackendErrorContext(
          service: BackendService.functions,
          action: 'ask Suvbot',
          resource: 'demoOpsRequests',
        ),
      );
}

@riverpod
SuvbotRepository suvbotRepository(Ref ref) =>
    SuvbotRepository(ref.watch(firebaseFunctionsProvider));

@riverpod
Future<List<SuvbotActionItem>> suvbotActions(Ref ref) =>
    ref.watch(suvbotRepositoryProvider).fetchActions();

String _stringField(Map<Object?, Object?> map, String key) {
  final value = map[key];
  if (value is String && value.trim().isNotEmpty) return value;
  throw StateError('Suvbot action response was missing $key.');
}
