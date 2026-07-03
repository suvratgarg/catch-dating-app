import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_control_shell.dart';
import 'package:catch_dating_app/explore/presentation/explore_screen_state.dart';
import 'package:flutter/material.dart';

enum ExploreCityPickerPresentation { icon, scopeLabel }

class ExploreCityPicker extends StatefulWidget {
  const ExploreCityPicker({
    super.key,
    required this.state,
    required this.onSelected,
    this.presentation = ExploreCityPickerPresentation.icon,
    this.foregroundColor,
  });

  final ExploreCityPickerState state;
  final ValueChanged<CityData>? onSelected;
  final ExploreCityPickerPresentation presentation;
  final Color? foregroundColor;

  @override
  State<ExploreCityPicker> createState() => _ExploreCityPickerState();
}

class _ExploreCityPickerState extends State<ExploreCityPicker> {
  bool _isSheetOpen = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.state.enabled && widget.onSelected != null;
    return CityTrigger(
      city: widget.state.selectedCity,
      enabled: enabled,
      focused: _isSheetOpen,
      presentation: widget.presentation,
      foregroundColor: widget.foregroundColor,
      onTap: enabled ? () => _showCitySheet(context) : null,
    );
  }

  Future<void> _showCitySheet(BuildContext context) async {
    final onSelected = widget.onSelected;
    if (onSelected == null || widget.state.cities.isEmpty) return;
    setState(() => _isSheetOpen = true);
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => ExploreCityPickerSheet(
        cities: widget.state.cities,
        selectedCity: widget.state.selectedCity,
        onSelected: (city) {
          onSelected(city);
          Navigator.of(sheetContext).pop();
        },
      ),
    );
    if (!mounted) return;
    setState(() => _isSheetOpen = false);
  }
}

class CityTrigger extends StatelessWidget {
  const CityTrigger({
    super.key,
    required this.city,
    required this.focused,
    this.presentation = ExploreCityPickerPresentation.icon,
    this.foregroundColor,
    this.enabled = true,
    this.onTap,
  });

  final CityData city;
  final bool focused;
  final ExploreCityPickerPresentation presentation;
  final Color? foregroundColor;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final effectiveForeground = foregroundColor ?? t.ink;
    final state = ExploreCityTriggerState.from(city: city, focused: focused);

    if (presentation == ExploreCityPickerPresentation.scopeLabel) {
      final labelColor = enabled ? effectiveForeground : t.ink3;
      return Tooltip(
        message: state.tooltipLabel,
        child: Semantics(
          button: true,
          enabled: enabled,
          label: state.semanticLabel,
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
                      state.scopeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CatchTextStyles.kicker(context, color: labelColor),
                    ),
                  ),
                  gapW4,
                  Icon(state.icon, color: labelColor, size: CatchIcon.sm),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Tooltip(
      message: state.tooltipLabel,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: state.semanticLabel,
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
            child: Icon(state.icon, size: 22, color: enabled ? t.ink : t.ink3),
          ),
        ),
      ),
    );
  }
}

class ExploreCityPickerSheet extends StatelessWidget {
  const ExploreCityPickerSheet({
    super.key,
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
                        style: CatchTextStyles.sectionTitle(context),
                      ),
                    ),
                    Icon(
                      CatchIcons.locationOnOutlined,
                      size: 18,
                      color: t.ink3,
                    ),
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
                        city.effectiveMarketId ==
                        selectedCity.effectiveMarketId;
                    return CityOptionTile(
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

class CityOptionTile extends StatelessWidget {
  const CityOptionTile({
    super.key,
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
}
