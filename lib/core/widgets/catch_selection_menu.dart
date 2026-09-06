import 'package:catch_dating_app/core/responsive/breakpoints.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_menu.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

@immutable
class CatchSelectionMenuItem<T> {
  const CatchSelectionMenuItem({
    required this.value,
    required this.label,
    this.sublabel,
    this.icon,
    this.enabled = true,
  });

  final T value;
  final String label;
  final String? sublabel;
  final IconData? icon;
  final bool enabled;
}

typedef CatchSelectionMenuTriggerBuilder<T> =
    Widget Function(
      BuildContext context,
      CatchSelectionMenuItem<T> selectedItem,
      bool open,
      VoidCallback toggle,
    );

/// Anchored, mutually-exclusive selection for medium and expanded layouts.
///
/// Compact layouts should use [CatchSelectionSheet] or
/// [CatchAdaptiveSelectionControl] so labels and touch targets remain legible.
class CatchSelectionMenu<T> extends StatefulWidget {
  CatchSelectionMenu({
    super.key,
    required this.items,
    required this.value,
    required this.onSelected,
    required this.builder,
    this.width = CatchLayout.selectionMenuWidth,
  }) : assert(items.isNotEmpty, 'CatchSelectionMenu needs at least one item.'),
       assert(
         items.any((item) => item.value == value),
         'CatchSelectionMenu value must match an item.',
       );

  final List<CatchSelectionMenuItem<T>> items;
  final T value;
  final ValueChanged<T> onSelected;
  final CatchSelectionMenuTriggerBuilder<T> builder;
  final double width;

  @override
  State<CatchSelectionMenu<T>> createState() => _CatchSelectionMenuState<T>();
}

class _CatchSelectionMenuState<T> extends State<CatchSelectionMenu<T>> {
  final _controller = MenuController();

  CatchSelectionMenuItem<T> get _selectedItem =>
      widget.items.firstWhere((item) => item.value == widget.value);

  @override
  Widget build(BuildContext context) {
    final menuWidth = CatchLayout.menuWidthFor(
      preferredWidth: widget.width,
      viewportWidth: MediaQuery.sizeOf(context).width,
    );
    return CatchMenuAnchor<T>(
      controller: _controller,
      width: menuWidth,
      alignmentOffset: const Offset(0, CatchSpacing.s1),
      items: [
        for (final item in widget.items)
          CatchMenuItem<T>(
            value: item.value,
            label: item.label,
            sublabel: item.sublabel,
            icon: item.icon,
            selected: item.value == widget.value,
            enabled: item.enabled,
            role: CatchMenuItemRole.choice,
          ),
      ],
      onSelected: (value, _) {
        if (value != widget.value) catchSelectionHaptic();
        widget.onSelected(value);
        _controller.close();
      },
      builder: (context, controller, child) => widget.builder(
        context,
        _selectedItem,
        controller.isOpen,
        () => controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}

/// Phone-friendly selection surface with mutually-exclusive row semantics.
class CatchSelectionSheet<T> extends StatelessWidget {
  const CatchSelectionSheet({
    super.key,
    required this.title,
    required this.items,
    required this.value,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<CatchSelectionMenuItem<T>> items;
  final T value;

  @override
  Widget build(BuildContext context) {
    final maxHeight =
        MediaQuery.sizeOf(context).height * CatchLayout.sheetMaxHeightFraction;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: CatchBottomSheetScaffold(
        title: title,
        subtitle: subtitle,
        child: Flexible(
          child: ListView(
            key: const ValueKey('catch-selection-sheet-list'),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: [
              for (final item in items)
                CatchMenuRow<T>(
                  key: ValueKey<Object?>(item.value),
                  item: CatchMenuItem<T>(
                    value: item.value,
                    label: item.label,
                    sublabel: item.sublabel,
                    icon: item.icon,
                    selected: item.value == value,
                    enabled: item.enabled,
                    role: CatchMenuItemRole.choice,
                  ),
                  onSelected: (selected, _) {
                    if (selected != value) catchSelectionHaptic();
                    Navigator.of(context).pop(selected);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<T?> showCatchSelectionSheet<T>({
  required BuildContext context,
  required String title,
  required List<CatchSelectionMenuItem<T>> items,
  required T value,
  String? subtitle,
}) => showCatchBottomSheet<T>(
  context: context,
  builder: (_) => CatchSelectionSheet<T>(
    title: title,
    subtitle: subtitle,
    items: items,
    value: value,
  ),
);

/// A standard visible selection control that uses a sheet on phones and an
/// anchored picker on wider Host layouts. Prefer this over an inline option
/// group when mutually-exclusive choices are numerous, long, or dynamic.
class CatchAdaptiveSelectionControl<T> extends StatelessWidget {
  const CatchAdaptiveSelectionControl({
    super.key,
    required this.title,
    required this.tooltip,
    required this.items,
    required this.value,
    required this.triggerLabel,
    required this.onSelected,
    this.subtitle,
    this.icon,
    this.buttonKey,
  });

  final String title;
  final String? subtitle;
  final String tooltip;
  final List<CatchSelectionMenuItem<T>> items;
  final T value;
  final String Function(CatchSelectionMenuItem<T> selectedItem) triggerLabel;
  final ValueChanged<T> onSelected;
  final IconData? icon;
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    return CatchAdaptiveSelectionMenu<T>(
      title: title,
      subtitle: subtitle,
      items: items,
      value: value,
      onSelected: onSelected,
      builder: (context, selectedItem, open, toggle) => CatchButton(
        key: buttonKey,
        label: triggerLabel(selectedItem),
        semanticsLabel: tooltip,
        icon: Icon(icon ?? CatchIcons.sort, size: CatchIcon.sm),
        variant: CatchButtonVariant.secondary,
        size: CatchButtonSize.sm,
        onPressed: toggle,
      ),
    );
  }
}

/// Adapts a caller-supplied selection trigger to a bottom sheet on compact
/// layouts and an anchored picker on wider layouts.
class CatchAdaptiveSelectionMenu<T> extends StatelessWidget {
  const CatchAdaptiveSelectionMenu({
    super.key,
    required this.title,
    required this.items,
    required this.value,
    required this.onSelected,
    required this.builder,
    this.subtitle,
    this.width = CatchLayout.selectionMenuWidth,
  });

  final String title;
  final String? subtitle;
  final List<CatchSelectionMenuItem<T>> items;
  final T value;
  final ValueChanged<T> onSelected;
  final CatchSelectionMenuTriggerBuilder<T> builder;
  final double width;

  CatchSelectionMenuItem<T> get _selectedItem =>
      items.firstWhere((item) => item.value == value);

  @override
  Widget build(BuildContext context) {
    final compact = ScreenSize.fromWidth(
      MediaQuery.sizeOf(context).width,
    ).isCompact;
    if (!compact) {
      return CatchSelectionMenu<T>(
        items: items,
        value: value,
        onSelected: onSelected,
        width: width,
        builder: builder,
      );
    }

    return builder(context, _selectedItem, false, () async {
      final selected = await showCatchSelectionSheet<T>(
        context: context,
        title: title,
        subtitle: subtitle,
        items: items,
        value: value,
      );
      if (selected != null && context.mounted) onSelected(selected);
    });
  }
}
