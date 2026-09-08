import 'package:catch_ui/src/components/catch_contract_field_constraints.dart';
import 'package:catch_ui/src/components/catch_icon_action.dart';
import 'package:catch_ui/src/components/catch_search_field_copy.dart';
import 'package:flutter/material.dart';

/// Immutable expanding-search contract shared by both Catch top bars.
///
/// Copy and interaction text are required so a top bar cannot silently fall
/// back to English. Passing no config removes the search affordance.
@immutable
class CatchTopBarSearch {
  const CatchTopBarSearch({
    required this.copy,
    this.fieldKey,
    required this.placeholder,
    required this.tooltip,
    this.value = '',
    this.contract,
    this.contractExemption,
    this.enabled = true,
    this.expanded,
    this.onExpandedChanged,
    this.onChanged,
    this.onSubmitted,
    this.onFocusChanged,
    this.semanticLabel,
    this.autofocus = false,
    this.textInputAction = TextInputAction.done,
    this.collapsedExtent = CatchIconAction.navSize,
    this.backgroundColor,
    this.borderColor,
    this.foregroundColor,
    this.mutedForegroundColor,
  });

  final CatchSearchFieldCopy copy;

  /// Stable identity for the rendered search field.
  final Key? fieldKey;
  final String value;
  final CatchContractFieldConstraints? contract;
  final String? contractExemption;
  final bool enabled;
  final bool? expanded;
  final ValueChanged<bool>? onExpandedChanged;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<bool>? onFocusChanged;
  final String placeholder;
  final String tooltip;
  final String? semanticLabel;
  final bool autofocus;
  final TextInputAction textInputAction;
  final double collapsedExtent;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? foregroundColor;
  final Color? mutedForegroundColor;
}
