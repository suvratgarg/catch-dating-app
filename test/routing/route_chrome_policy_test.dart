import 'dart:io';

import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app shell child routes render on the root navigator', () {
    final source = File('lib/routing/go_router.dart').readAsStringSync();

    for (final route in <Routes>[
      Routes.notificationsScreen,
      Routes.eventRecapScreen,
      Routes.clubDetailScreen,
      Routes.eventDetailScreen,
      Routes.chatScreen,
      Routes.hostClubDetailScreen,
      Routes.hostAppEventDetailScreen,
      Routes.hostChatScreen,
      Routes.hostProfileScreen,
    ]) {
      expect(
        _routeBlock(source, route),
        contains('parentNavigatorKey: _rootNavigatorKey'),
        reason: '${route.name} must sit above the floating tab shell.',
      );
    }
  });
}

String _routeBlock(String source, Routes route) {
  final routeName = 'name: Routes.${route.name}.name,';
  final nameOffset = source.indexOf(routeName);
  expect(nameOffset, isNot(-1), reason: 'Missing route ${route.name}.');

  final routeStart = source.lastIndexOf('GoRoute(', nameOffset);
  expect(routeStart, isNot(-1), reason: 'Missing GoRoute for ${route.name}.');

  final nextRouteStart = source.indexOf('GoRoute(', nameOffset + 1);
  return source.substring(
    routeStart,
    nextRouteStart == -1 ? source.length : nextRouteStart,
  );
}
