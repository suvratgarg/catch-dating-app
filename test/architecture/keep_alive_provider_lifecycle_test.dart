import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/event_success/event_success_companion_launcher.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_live_effects_controller.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
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

    test(
      'Explore city selection keeps manual choice and guard across listeners',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final subscription = container.listen(
          selectedExploreCityProvider,
          (_, _) {},
        );
        final delhi = cityOptionByName('delhi')!.toCityData();
        final mumbai = cityOptionByName('mumbai')!.toCityData();

        container.read(selectedExploreCityProvider.notifier).setCity(delhi);
        expect(subscription.read(), delhi);
        expect(
          container.read(selectedExploreCityWasUserSelectedProvider),
          true,
        );

        subscription.close();
        await container.pump();

        container
            .read(selectedExploreCityProvider.notifier)
            .autoSelectCity(mumbai);
        expect(container.read(selectedExploreCityProvider), delhi);
        expect(
          container.read(selectedExploreCityWasUserSelectedProvider),
          true,
        );
      },
    );

    test('Explore search query survives listener disposal', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final subscription = container.listen(
        exploreSearchQueryProvider,
        (_, _) {},
      );
      container.read(exploreSearchQueryProvider.notifier).setQuery('  dinner');
      expect(subscription.read(), 'dinner');

      subscription.close();
      await container.pump();

      expect(container.read(exploreSearchQueryProvider), 'dinner');
    });

    test('Explore filters survive listener disposal', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final subscription = container.listen(exploreFiltersProvider, (_, _) {});
      container
          .read(exploreFiltersProvider.notifier)
          .setTimeFilter(ExploreTimeFilter.thisWeek);
      container
          .read(exploreFiltersProvider.notifier)
          .setDistanceFilter(ExploreDistanceFilter.fiveKm);
      expect(subscription.read().timeFilter, ExploreTimeFilter.thisWeek);
      expect(subscription.read().distanceFilter, ExploreDistanceFilter.fiveKm);

      subscription.close();
      await container.pump();

      final retainedFilters = container.read(exploreFiltersProvider);
      expect(retainedFilters.timeFilter, ExploreTimeFilter.thisWeek);
      expect(retainedFilters.distanceFilter, ExploreDistanceFilter.fiveKm);
    });
  });
}
