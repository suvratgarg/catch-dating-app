import 'package:catch_dating_app/routing/go_router.dart';

const _deepLinkHost = 'catchdates.com';

class AppDeepLinks {
  const AppDeepLinks._();

  static Uri runClub(String runClubId) => _httpsRoute(
    Routes.runClubDetailScreen.path,
    pathParameters: {'runClubId': runClubId},
  );

  static Uri run({required String runClubId, required String runId}) =>
      _httpsRoute(
        Routes.runDetailScreen.path,
        pathParameters: {'runClubId': runClubId, 'runId': runId},
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
