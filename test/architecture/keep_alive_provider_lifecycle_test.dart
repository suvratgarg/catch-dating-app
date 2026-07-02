import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/event_success/event_success_companion_launcher.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_live_effects_controller.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(AppConfig.resetEntrypointRoleOverrideForTesting);

  group('keepAlive provider lifecycle', () {
    test(
      'companion launch registry retains de-dupe state without listeners',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final subscription = container.listen(
          eventSuccessCompanionLaunchRegistryProvider,
          (_, _) {},
        );
        final registry = subscription.read();

        expect(
          registry.claimLaunch(
            eventId: 'event-1',
            moment: EventSuccessCompanionLaunchMoment.checkedIn,
          ),
          isTrue,
        );

        subscription.close();
        await container.pump();

        final retainedRegistry = container.read(
          eventSuccessCompanionLaunchRegistryProvider,
        );
        expect(identical(retainedRegistry, registry), isTrue);
        expect(
          retainedRegistry.claimLaunch(
            eventId: 'event-1',
            moment: EventSuccessCompanionLaunchMoment.checkedIn,
          ),
          isFalse,
        );
      },
    );

    test(
      'live effects controller keeps imperative controller instance',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final subscription = container.listen(
          eventSuccessLiveEffectsControllerProvider,
          (_, _) {},
        );
        final controller = subscription.read();

        subscription.close();
        await container.pump();

        expect(
          identical(
            container.read(eventSuccessLiveEffectsControllerProvider),
            controller,
          ),
          isTrue,
        );
      },
    );

    test(
      'initial app location stays fixed for the container lifetime',
      () async {
        AppConfig.configureEntrypointRole(AppRole.host);
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final subscription = container.listen(
          initialAppLocationProvider,
          (_, _) {},
        );
        final initialLocation = subscription.read();
        expect(initialLocation, Routes.hostHomeScreen.path);

        subscription.close();
        await container.pump();

        AppConfig.configureEntrypointRole(AppRole.consumer);
        expect(container.read(initialAppLocationProvider), initialLocation);
      },
    );
  });
}
