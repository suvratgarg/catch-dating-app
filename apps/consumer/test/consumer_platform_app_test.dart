import 'package:catch_consumer_app/consumer_platform_app.dart';
import 'package:catch_dating_app/app.dart';
import 'package:catch_dating_app/payments/data/razorpay_checkout.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Consumer root installs Consumer routing and native provider overrides',
    () {
      final root = const ConsumerPlatformApp().build(_FakeBuildContext());

      expect(root, isA<ConsumerPlatformScope>());
      final platformScope = root as ConsumerPlatformScope;
      expect(platformScope.child, isA<MyApp>());
      expect(
        (platformScope.child as MyApp).routerProvider,
        same(consumerGoRouterProvider),
      );

      final scope = platformScope.build(_FakeBuildContext());
      expect(scope, isA<ProviderScope>());
      expect((scope as ProviderScope).overrides, hasLength(2));
      expect(scope.child, same(platformScope.child));
    },
  );

  testWidgets('reusable platform scope exposes native checkout', (
    tester,
  ) async {
    RazorpayCheckoutFactory? observedFactory;
    await tester.pumpWidget(
      ConsumerPlatformScope(
        child: Consumer(
          builder: (context, ref, child) {
            observedFactory = ref.watch(razorpayCheckoutFactoryProvider);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(observedFactory, isNotNull);
  });
}

class _FakeBuildContext extends Fake implements BuildContext {}
