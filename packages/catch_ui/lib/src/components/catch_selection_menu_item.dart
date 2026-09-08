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
