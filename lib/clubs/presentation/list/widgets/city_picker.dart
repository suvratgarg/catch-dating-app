import 'package:catch_dating_app/clubs/presentation/list/clubs_list_view_model.dart';
import 'package:catch_dating_app/core/data/city_repository.dart';
import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_control_shell.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CityPicker extends ConsumerStatefulWidget {
  const CityPicker({super.key});

  @override
  ConsumerState<CityPicker> createState() => _CityPickerState();
}

class _CityPickerState extends ConsumerState<CityPicker> {
  bool _isSheetOpen = false;

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
    final selectedCity = ref.watch(selectedClubCityProvider);
    final citiesAsync = ref.watch(cityListProvider);

    ref.listen(deviceLocationProvider, (_, next) {
      next.whenData((_) => _tryAutoSelectFromGps());
    });
    ref.listen(watchUserProfileProvider, (_, next) {
      next.whenData((_) => _tryAutoSelectFromProfile());
    });

    return citiesAsync.when(
      data: (cities) => _CityTrigger(
        city: selectedCity,
        focused: _isSheetOpen,
        onTap: cities.isEmpty ? null : () => _showCitySheet(context, cities),
      ),
      loading: () => _disabledTrigger(selectedCity),
      error: (_, _) => _disabledTrigger(selectedCity),
    );
  }

  Widget _disabledTrigger(CityData city) {
    return _CityTrigger(city: city, enabled: false, focused: false);
  }

  Future<void> _showCitySheet(
    BuildContext context,
    List<CityData> cities,
  ) async {
    setState(() => _isSheetOpen = true);
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _CityPickerSheet(
        cities: cities,
        selectedCity: ref.read(selectedClubCityProvider),
        onSelected: (city) {
          ref.read(selectedClubCityProvider.notifier).setCity(city);
          Navigator.of(sheetContext).pop();
        },
      ),
    );
    if (!mounted) return;
    setState(() => _isSheetOpen = false);
  }

  void _tryAutoSelectFromProfile() {
    final cityName = ref.read(watchUserProfileProvider).asData?.value?.city;
    ref.read(selectedClubCityProvider.notifier).autoSelectCityByName(cityName);
  }

  Future<void> _tryAutoSelectFromGps() async {
    final location = ref.read(deviceLocationProvider).asData?.value;
    if (location == null) return;
    final nearest = await ref
        .read(cityRepositoryProvider)
        .nearestCity(location.latitude, location.longitude);
    if (nearest != null) {
      ref.read(selectedClubCityProvider.notifier).autoSelectCity(nearest);
    }
  }
}

class _CityTrigger extends StatelessWidget {
  const _CityTrigger({
    required this.city,
    required this.focused,
    this.enabled = true,
    this.onTap,
  });

  final CityData city;
  final bool enabled;
  final bool focused;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Tooltip(
      message: 'Choose city: ${city.label}',
      child: Semantics(
        button: true,
        enabled: enabled,
        label: 'Choose city: ${city.label}',
        child: CatchControlShell(
          size: CatchControlSize.compact,
          shape: CatchControlShape.pill,
          tone: CatchControlTone.raised,
          enabled: enabled,
          focused: focused,
          onTap: enabled ? onTap : null,
          padding: EdgeInsets.zero,
          child: SizedBox.square(
            dimension: CatchControlMetrics.compactIconExtent,
            child: Icon(
              focused ? Icons.location_on_rounded : Icons.location_on_outlined,
              size: 22,
              color: enabled ? t.ink : t.ink3,
            ),
          ),
        ),
      ),
    );
  }
}

class _CityPickerSheet extends StatelessWidget {
  const _CityPickerSheet({
    required this.cities,
    required this.selectedCity,
    required this.onSelected,
  });

  final List<CityData> cities;
  final CityData selectedCity;
  final ValueChanged<CityData> onSelected;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.68;

    return Material(
      color: t.surface,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(CatchRadius.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  CatchSpacing.s5,
                  CatchSpacing.s3,
                  CatchSpacing.s5,
                  CatchSpacing.s2,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'City',
                        style: CatchTextStyles.titleM(context),
                      ),
                    ),
                    Icon(Icons.location_on_outlined, size: 18, color: t.ink3),
                  ],
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(
                    CatchSpacing.s3,
                    0,
                    CatchSpacing.s3,
                    CatchSpacing.s4,
                  ),
                  itemCount: cities.length,
                  separatorBuilder: (_, _) => gapH2,
                  itemBuilder: (context, index) {
                    final city = cities[index];
                    final selected = city.name == selectedCity.name;
                    return _CityOptionTile(
                      city: city,
                      selected: selected,
                      onTap: () => onSelected(city),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CityOptionTile extends StatelessWidget {
  const _CityOptionTile({
    required this.city,
    required this.selected,
    required this.onTap,
  });

  final CityData city;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Semantics(
      button: true,
      selected: selected,
      label: 'Select ${city.label}',
      child: Material(
        color: selected ? t.primarySoft : Colors.transparent,
        borderRadius: BorderRadius.circular(CatchRadius.sm),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: CatchSpacing.s4,
              vertical: CatchSpacing.s3,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    city.label,
                    style: CatchTextStyles.bodyL(
                      context,
                      color: selected ? t.primary : t.ink,
                    ),
                  ),
                ),
                if (selected)
                  Icon(Icons.check_rounded, size: 18, color: t.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
