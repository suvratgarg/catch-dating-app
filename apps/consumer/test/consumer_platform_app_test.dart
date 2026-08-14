import 'package:catch_consumer_app/consumer_platform_app.dart';
import 'package:catch_dating_app/app.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Consumer root installs Consumer routing and native provider overrides',
    () {
      final root = const ConsumerPlatformApp().build(_FakeBuildContext());

      expect(root, isA<ProviderScope>());
      final scope = root as ProviderScope;
      expect(scope.overrides, hasLength(2));
      expect(scope.child, isA<MyApp>());
      expect(
        (scope.child as MyApp).routerProvider,
        same(consumerGoRouterProvider),
      );
    },
  );
}

class _FakeBuildContext extends Fake implements BuildContext {}
