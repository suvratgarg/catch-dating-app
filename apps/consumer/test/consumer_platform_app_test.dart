import 'package:catch_consumer_app/consumer_platform_app.dart';
import 'package:catch_dating_app/app.dart';
import 'package:catch_dating_app/app_bootstrap.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/payments/data/payment_repository.dart';
import 'package:catch_dating_app/payments/data/razorpay_checkout.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Consumer root installs Consumer routing', () {
    final root = const ConsumerPlatformApp().build(_FakeBuildContext());
    expect(root, isA<MyApp>());
    expect((root as MyApp).routerProvider, same(consumerGoRouterProvider));
  });

  test(
    'bootstrap native bindings reach repositories through nested scopes',
    () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final bootstrap = createCatchProviderContainer(
        overrides: [
          firebaseFunctionsProvider.overrideWithValue(_FakeFunctions()),
          ...consumerPlatformOverrides(),
        ],
      );
      final initializedApp = ProviderContainer(parent: bootstrap);
      final screen = ProviderContainer(parent: initializedApp);
      addTearDown(() {
        screen.dispose();
        initializedApp.dispose();
        bootstrap.dispose();
      });
      expect(screen.read(razorpayCheckoutFactoryProvider), isNotNull);
      expect(
        screen
            .read(paymentRepositoryProvider)
            .supportsPaidBookingsForCurrency('INR'),
        isTrue,
      );
      expect(
        screen.read(paymentRepositoryProvider),
        same(bootstrap.read(paymentRepositoryProvider)),
      );
    },
  );

  test(
    'bootstrap without native bindings retains unsupported INR checkout',
    () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final bootstrap = createCatchProviderContainer(
        overrides: [
          firebaseFunctionsProvider.overrideWithValue(_FakeFunctions()),
        ],
      );
      addTearDown(bootstrap.dispose);
      expect(bootstrap.read(razorpayCheckoutFactoryProvider), isNull);
      expect(
        bootstrap
            .read(paymentRepositoryProvider)
            .supportsPaidBookingsForCurrency('INR'),
        isFalse,
      );
    },
  );
}

class _FakeBuildContext extends Fake implements BuildContext {}

class _FakeFunctions extends Fake implements FirebaseFunctions {}
