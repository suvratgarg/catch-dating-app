import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

class CityPicker extends StatelessWidget {
  const CityPicker({
    super.key,
    required this.selectedCity,
    required this.onSelected,
  });

  final IndianCity selectedCity;
  final ValueChanged<IndianCity> onSelected;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return PopupMenuButton<IndianCity>(
      tooltip: 'Change city',
      initialValue: selectedCity,
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final city in IndianCity.values)
          PopupMenuItem<IndianCity>(value: city, child: Text(city.label)),
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
    );
  }
}
