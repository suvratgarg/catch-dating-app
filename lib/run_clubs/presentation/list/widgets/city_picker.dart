import 'package:catch_dating_app/core/data/city_repository.dart';
import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/core/widgets/catch_select_menu.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/run_clubs_list_view_model.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CityPicker extends ConsumerStatefulWidget {
  const CityPicker({super.key});

  @override
  ConsumerState<CityPicker> createState() => _CityPickerState();
}

class _CityPickerState extends ConsumerState<CityPicker> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryAutoSelectFromProfile();
      _tryAutoSelectFromGps();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedCity = ref.watch(selectedRunClubCityProvider);
    final citiesAsync = ref.watch(cityListProvider);

    ref.listen(deviceLocationProvider, (_, next) {
      next.whenData((_) => _tryAutoSelectFromGps());
    });
    ref.listen(watchUserProfileProvider, (_, next) {
      next.whenData((_) => _tryAutoSelectFromProfile());
    });

    return citiesAsync.when(
      data: (cities) => CatchSelectMenu<CityData>(
        values: cities,
        value: selectedCity,
        itemLabel: (city) => city.label,
        prefixIcon: const Icon(Icons.location_on_outlined),
        semanticLabel: 'City',
        size: CatchSelectMenuSize.compact,
        shape: CatchSelectMenuShape.pill,
        onChanged: (city) {
          if (city == null) return;
          ref.read(selectedRunClubCityProvider.notifier).setCity(city);
        },
      ),
      loading: () => _disabledTrigger(selectedCity),
      error: (_, _) => _disabledTrigger(selectedCity),
    );
  }

  Widget _disabledTrigger(CityData city) {
    return CatchSelectMenu<CityData>(
      values: [city],
      value: city,
      itemLabel: (city) => city.label,
      prefixIcon: const Icon(Icons.location_on_outlined),
      semanticLabel: 'City',
      enabled: false,
      size: CatchSelectMenuSize.compact,
      shape: CatchSelectMenuShape.pill,
    );
  }

  void _tryAutoSelectFromProfile() {
    final cityName = ref.read(watchUserProfileProvider).asData?.value?.city;
    ref
        .read(selectedRunClubCityProvider.notifier)
        .autoSelectCityByName(cityName);
  }

  Future<void> _tryAutoSelectFromGps() async {
    final location = ref.read(deviceLocationProvider).asData?.value;
    if (location == null) return;
    final nearest = await ref
        .read(cityRepositoryProvider)
        .nearestCity(location.latitude, location.longitude);
    if (nearest != null) {
      ref.read(selectedRunClubCityProvider.notifier).autoSelectCity(nearest);
    }
  }
}
