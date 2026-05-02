import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:flutter/material.dart';

/// Uppercase section title used to group settings, filters, and activity
/// sections — replaces ad-hoc title labels in _SettingsGroup, _FilterSection,
/// and _ActivitySectionTitle.
///
/// Usage:
/// ```dart
/// SectionHeader(title: 'Account')
/// SectionHeader(title: 'Notifications', trailing: TextButton(...))
/// ```
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(title.toUpperCase(), style: CatchTextStyles.labelM(context)),
          if (trailing != null) ...[const Spacer(), trailing!],
        ],
      ),
    );
  }
}
