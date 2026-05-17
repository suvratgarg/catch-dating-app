import 'package:catch_dating_app/routing/go_router.dart';

const _deepLinkHost = 'catchdates.com';

class AppDeepLinks {
  const AppDeepLinks._();

  static Uri club(String clubId) => _httpsRoute(
    Routes.clubDetailScreen.path,
    pathParameters: {'clubId': clubId},
  );

  static Uri event({required String clubId, required String eventId}) =>
      _httpsRoute(
        Routes.eventDetailScreen.path,
        pathParameters: {'clubId': clubId, 'eventId': eventId},
      );
}

Uri _httpsRoute(
  String routePath, {
  required Map<String, String> pathParameters,
}) {
  final pathSegments = routePath
      .split('/')
      .where((segment) => segment.isNotEmpty)
      .map((segment) {
        if (!segment.startsWith(':')) return segment;

        final key = segment.substring(1);
        final value = pathParameters[key];
        if (value == null || value.isEmpty) {
          throw ArgumentError.value(value, key, 'Missing route path parameter');
        }
        return value;
      })
      .toList(growable: false);

  return Uri(scheme: 'https', host: _deepLinkHost, pathSegments: pathSegments);
}
