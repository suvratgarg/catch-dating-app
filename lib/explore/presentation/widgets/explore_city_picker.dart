import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/explore/presentation/explore_screen_state.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

enum ExploreCityPickerPresentation { icon, scopeLabel }

class ExploreCityPicker extends StatefulWidget {
  const ExploreCityPicker({
    super.key,
    required this.state,
    required this.onSelected,
    this.presentation = ExploreCityPickerPresentation.icon,
    this.foregroundColor,
    this.backgroundColor,
    this.borderColor,
  });

  final ExploreCityPickerState state;
  final ValueChanged<CityData>? onSelected;
  final ExploreCityPickerPresentation presentation;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? borderColor;

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
      backgroundColor: widget.backgroundColor,
      borderColor: widget.borderColor,
      onTap: enabled ? () => _showCitySheet(context) : null,
    );
  }

  Future<void> _showCitySheet(BuildContext context) async {
    final onSelected = widget.onSelected;
    if (onSelected == null || widget.state.cities.isEmpty) return;
    setState(() => _isSheetOpen = true);
    await showExploreCityPickerSheet(
      context: context,
      state: widget.state,
      onSelected: onSelected,
    );
    if (!mounted) return;
    setState(() => _isSheetOpen = false);
  }
}

Future<void> showExploreCityPickerSheet({
  required BuildContext context,
  required ExploreCityPickerState state,
  required ValueChanged<CityData> onSelected,
}) {
  if (!state.enabled || state.cities.isEmpty) return Future.value();
  return showCatchBottomSheet<void>(
    context: context,
    builder: (sheetContext) => ExploreCityPickerSheet(
      cities: state.cities,
      selectedCity: state.selectedCity,
      onSelected: (city) {
        onSelected(city);
        Navigator.of(sheetContext).pop();
      },
    ),
  );
}

class CityTrigger extends StatelessWidget {
  const CityTrigger({
    super.key,
    required this.city,
    required this.focused,
    this.presentation = ExploreCityPickerPresentation.icon,
    this.foregroundColor,
    this.backgroundColor,
    this.borderColor,
    this.enabled = true,
    this.onTap,
  });

  final CityData city;
  final bool focused;
  final ExploreCityPickerPresentation presentation;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final effectiveForeground = foregroundColor ?? t.ink;
    final state = ExploreCityTriggerState.from(
      city: city,
      focused: focused,
      l10n: context.l10n,
    );

    final labelColor = enabled ? effectiveForeground : t.ink3;
    return Tooltip(
      message: state.tooltipLabel,
      excludeFromSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 132),
        child: CatchButton(
          label: presentation == ExploreCityPickerPresentation.scopeLabel
              ? state.scopeLabel
              : city.label,
          semanticsLabel: state.semanticLabel,
          icon: Icon(state.icon),
          variant: CatchButtonVariant.secondary,
          backgroundColor:
              backgroundColor ??
              (presentation == ExploreCityPickerPresentation.scopeLabel
                  ? Colors.transparent
                  : t.surface),
          foregroundColor: labelColor,
          borderColor: borderColor ?? t.line2,
          onPressed: enabled ? onTap : null,
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
    final maxHeight =
        MediaQuery.sizeOf(context).height * CatchLayout.sheetMaxHeightFraction;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: CatchBottomSheetScaffold(
        title: context.l10n.exploreExploreCityPickerTextCity,
        trailing: Icon(CatchIcons.locationOnOutlined, size: 18, color: t.ink3),
        child: Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: cities.length,
            separatorBuilder: (_, _) => gapH2,
            itemBuilder: (context, index) {
              final city = cities[index];
              final selected =
                  city.effectiveMarketId == selectedCity.effectiveMarketId;
              return CityOptionTile(
                city: city,
                selected: selected,
                onTap: () => onSelected(city),
              );
            },
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
      label: context.l10n.exploreExploreCityPickerLabelSelectLabel(
        label: city.label,
      ),
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
