import 'package:catch_dating_app/core/data/city_repository.dart';
import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_control_shell.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ExploreCityPickerPresentation { icon, scopeLabel }

class ExploreCityPicker extends ConsumerStatefulWidget {
  const ExploreCityPicker({
    super.key,
    this.presentation = ExploreCityPickerPresentation.icon,
    this.foregroundColor,
  });

  final ExploreCityPickerPresentation presentation;
  final Color? foregroundColor;

  @override
  ConsumerState<ExploreCityPicker> createState() => _ExploreCityPickerState();
}

class _ExploreCityPickerState extends ConsumerState<ExploreCityPicker> {
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
    final selectedCity = ref.watch(selectedExploreCityProvider);
    final citiesAsync = ref.watch(cityListProvider);

    ref.listen(deviceLocationProvider, (_, next) {
      next.whenData((_) => _tryAutoSelectFromGps());
    });
    ref.listen(watchUserProfileProvider, (_, next) {
      next.whenData((_) => _tryAutoSelectFromProfile());
    });

    return citiesAsync.when(
      data: (cities) => _buildCityTrigger(
        context,
        city: selectedCity,
        focused: _isSheetOpen,
        presentation: widget.presentation,
        foregroundColor: widget.foregroundColor,
        onTap: cities.isEmpty ? null : () => _showCitySheet(context, cities),
      ),
      loading: () => _disabledTrigger(selectedCity),
      error: (_, _) => _disabledTrigger(selectedCity),
    );
  }

  Widget _disabledTrigger(CityData city) {
    return _buildCityTrigger(
      context,
      city: city,
      enabled: false,
      focused: false,
      presentation: widget.presentation,
      foregroundColor: widget.foregroundColor,
    );
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
      builder: (sheetContext) => _buildExploreCityPickerSheet(
        sheetContext,
        cities: cities,
        selectedCity: ref.read(selectedExploreCityProvider),
        onSelected: (city) {
          ref.read(selectedExploreCityProvider.notifier).setCity(city);
          Navigator.of(sheetContext).pop();
        },
      ),
    );
    if (!mounted) return;
    setState(() => _isSheetOpen = false);
  }

  void _tryAutoSelectFromProfile() {
    final cityName = ref.read(watchUserProfileProvider).asData?.value?.city;
    ref
        .read(selectedExploreCityProvider.notifier)
        .autoSelectCityByName(cityName);
  }

  Future<void> _tryAutoSelectFromGps() async {
    final location = ref.read(deviceLocationProvider).asData?.value;
    if (location == null) return;
    final nearest = await ref
        .read(cityRepositoryProvider)
        .nearestCity(location.latitude, location.longitude);
    if (nearest != null) {
      ref.read(selectedExploreCityProvider.notifier).autoSelectCity(nearest);
    }
  }
}

Widget _buildCityTrigger(
  BuildContext context, {
  required CityData city,
  required bool focused,
  ExploreCityPickerPresentation presentation =
      ExploreCityPickerPresentation.icon,
  Color? foregroundColor,
  bool enabled = true,
  VoidCallback? onTap,
}) {
  final t = CatchTokens.of(context);
  final effectiveForeground = foregroundColor ?? t.ink;

  if (presentation == ExploreCityPickerPresentation.scopeLabel) {
    final labelColor = enabled ? effectiveForeground : t.ink3;
    return Tooltip(
      message: 'Choose city: ${city.label}',
      child: Semantics(
        button: true,
        enabled: enabled,
        label: 'Choose city: ${city.label}',
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(CatchRadius.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: CatchSpacing.s2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    'EXPLORE · ${city.label}'.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.kicker(context, color: labelColor),
                  ),
                ),
                gapW4,
                Icon(
                  focused
                      ? CatchIcons.locationOnRounded
                      : CatchIcons.locationOnOutlined,
                  color: labelColor,
                  size: CatchIcon.sm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
            focused
                ? CatchIcons.locationOnRounded
                : CatchIcons.locationOnOutlined,
            size: 22,
            color: enabled ? t.ink : t.ink3,
          ),
        ),
      ),
    ),
  );
}

Widget _buildExploreCityPickerSheet(
  BuildContext context, {
  required List<CityData> cities,
  required CityData selectedCity,
  required ValueChanged<CityData> onSelected,
}) {
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
                      style: CatchTextStyles.sectionTitle(context),
                    ),
                  ),
                  Icon(CatchIcons.locationOnOutlined, size: 18, color: t.ink3),
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
                  final selected =
                      city.effectiveMarketId == selectedCity.effectiveMarketId;
                  return _buildCityOptionTile(
                    context,
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

Widget _buildCityOptionTile(
  BuildContext context, {
  required CityData city,
  required bool selected,
  required VoidCallback onTap,
}) {
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
          padding: CatchInsets.listBody,
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
                Icon(
                  CatchIcons.checkRounded,
                  size: CatchIcon.md,
                  color: t.primary,
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
