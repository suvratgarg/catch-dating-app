import 'package:catch_dating_app/hosts/data/host_forms_repository.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_response.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'multiple answers and combined questions survive pagination serialization',
    () async {
      final functions = _Functions();
      final repository = HostFormsRepository(functions);
      const request = HostFormResponseListRequest(
        organizerId: 'org',
        formId: 'form',
        answerFilters: {
          'city': {'Mumbai', 'Delhi'},
          'diet': {'vegetarian', 'vegan'},
        },
      );
      await repository.listResponses(request.copyWith(cursor: 'next'));
      expect(functions.payload['cursor'], 'next');
      expect(functions.payload['answerFilters'], [
        {
          'questionId': 'city',
          'values': ['Delhi', 'Mumbai'],
        },
        {
          'questionId': 'diet',
          'values': ['vegan', 'vegetarian'],
        },
      ]);
    },
  );
}

class _Functions extends Fake implements FirebaseFunctions {
  Map<Object?, Object?> payload = {};
  @override
  HttpsCallable httpsCallable(String name, {HttpsCallableOptions? options}) =>
      _Callable((value) => payload = value);
}

class _Callable extends Fake implements HttpsCallable {
  _Callable(this.onCall);
  final void Function(Map<Object?, Object?>) onCall;
  @override
  Future<HttpsCallableResult<T>> call<T>([dynamic parameters]) async {
    onCall(parameters as Map<Object?, Object?>);
    return _Result<T>(
      {'organizerId': 'org', 'items': [], 'nextCursor': null} as T,
    );
  }
}

class _Result<T> extends Fake implements HttpsCallableResult<T> {
  _Result(this.data);
  @override
  final T data;
}
