import 'package:catch_dating_app/core/data/city_repository.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CityPicker extends ConsumerWidget {
  const CityPicker({
    super.key,
    required this.selectedCity,
    required this.onSelected,
  });

  final CityData selectedCity;
  final ValueChanged<CityData> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final citiesAsync = ref.watch(cityListProvider);

    return citiesAsync.when(
      data: (cities) => PopupMenuButton<CityData>(
        tooltip: 'Change city',
        initialValue: selectedCity,
        onSelected: onSelected,
        itemBuilder: (context) => [
          for (final city in cities)
            PopupMenuItem<CityData>(
              value: city,
              child: Text(city.label),
            ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(CatchRadius.pill),
            border: Border.all(color: t.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: t.ink2),
              const SizedBox(width: 6),
              Text(
                selectedCity.label,
                style: CatchTextStyles.labelL(context, color: t.ink),
              ),
              const SizedBox(width: 4),
              Icon(Icons.expand_more_rounded, size: 18, color: t.ink2),
            ],
          ),
        ),
      ),
      // Before the city list loads, show the selected city name.
      loading: () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(CatchRadius.pill),
          border: Border.all(color: t.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on_outlined, size: 16, color: t.ink2),
            const SizedBox(width: 6),
            Text(
              selectedCity.label,
              style: CatchTextStyles.labelL(context, color: t.ink),
            ),
            const SizedBox(width: 4),
            Icon(Icons.expand_more_rounded, size: 18, color: t.ink2),
          ],
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
