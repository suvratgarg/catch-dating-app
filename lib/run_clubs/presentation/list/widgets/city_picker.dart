import 'package:catch_dating_app/core/data/city_repository.dart';
import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/run_clubs_list_view_model.dart';
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

    return citiesAsync.when(
      data: (cities) => PopupMenuButton<CityData>(
        tooltip: 'Change city',
        initialValue: selectedCity,
        onSelected: (city) =>
            ref.read(selectedRunClubCityProvider.notifier).setCity(city),
        itemBuilder: (context) => [
          for (final city in cities)
            PopupMenuItem<CityData>(value: city, child: Text(city.label)),
        ],
        child: _trigger(context, selectedCity),
      ),
      loading: () => _trigger(context, selectedCity),
      error: (_, _) => _trigger(context, selectedCity),
    );
  }

  Widget _trigger(BuildContext context, CityData city) {
    final t = CatchTokens.of(context);

    return Semantics(
      button: true,
      label: 'City',
      value: city.label,
      hint: 'Change run club city',
      child: Container(
        height: CatchTextField.compactControlHeight,
        padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s3),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(CatchRadius.pill),
          border: Border.all(color: t.line2, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on_outlined, size: 18, color: t.ink3),
            const SizedBox(width: CatchSpacing.s2),
            Text(
              city.label,
              style: CatchTextStyles.bodyL(context, color: t.ink),
            ),
            const SizedBox(width: CatchSpacing.s1),
            Icon(Icons.expand_more_rounded, size: 20, color: t.ink3),
          ],
        ),
      ),
    );
  }

  Future<void> _tryAutoSelectFromGps() async {
    final location = ref.read(deviceLocationProvider).asData?.value;
    if (location == null) return;
    final repo = CityRepository(ref.read(firebaseFirestoreProvider));
    final nearest = await repo.nearestCity(
      location.latitude,
      location.longitude,
    );
    if (nearest != null) {
      ref.read(selectedRunClubCityProvider.notifier).autoSelectCity(nearest);
    }
  }
}
