import 'dart:async';

import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:flutter/services.dart';
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

      expect(root, isA<ProviderScope>());
      final platformScope = root as ProviderScope;
      expect(platformScope.overrides, hasLength(2));
      expect(platformScope.child, isA<MyApp>());
      expect(
        (platformScope.child as MyApp).routerProvider,
        same(consumerGoRouterProvider),
      );
    },
  );

  testWidgets('reusable platform overrides expose native checkout', (
    tester,
  ) async {
    RazorpayCheckoutFactory? observedFactory;
    await tester.pumpWidget(
      ProviderScope(
        overrides: consumerPlatformOverrides(),
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

  testWidgets(
    'root override-list recreation retains an unresolved native lease',
    (tester) async {
      const channel = MethodChannel('razorpay_flutter');
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      final native = Completer<Object?>();
      var openCalls = 0;
      messenger.setMockMethodCallHandler(channel, (call) {
        expect(call.method, 'open');
        openCalls++;
        return native.future;
      });
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
      RazorpayCheckoutFactory? observedFactory;
      Widget root() {
        final platform =
            const ConsumerPlatformApp().build(_FakeBuildContext())
                as ProviderScope;
        return ProviderScope(
          overrides: platform.overrides,
          child: Consumer(
            builder: (context, ref, child) {
              observedFactory = ref.watch(razorpayCheckoutFactoryProvider);
              return const SizedBox.shrink();
            },
          ),
        );
      }

      await tester.pumpWidget(root());
      final initialFactory = observedFactory!;
      final checkout = initialFactory();
      checkout.configure(
        onSuccess: (_) async => fail('Detached success'),
        onFailure: (_) => fail('Detached failure'),
      );
      checkout.open({
        'key': 'rzp_test',
        'order_id': 'order-a',
        'amount': 25000,
      });
      await tester.pump();
      checkout.clear();
      for (var rebuild = 0; rebuild < 3; rebuild++) {
        await tester.pumpWidget(root());
        expect(observedFactory, same(initialFactory));
        expect(observedFactory!, throwsA(isA<PaymentFailedException>()));
      }
      expect(openCalls, 1);
      native.complete({
        'type': 1,
        'data': {'code': 2, 'message': 'Cancelled'},
      });
      await tester.pump();
      observedFactory!().clear();
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}

class _FakeBuildContext extends Fake implements BuildContext {}
