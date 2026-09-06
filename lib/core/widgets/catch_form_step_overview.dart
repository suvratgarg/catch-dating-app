import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_form_step_flow.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

Future<int?> showCatchFormStepOverview({
  required BuildContext context,
  required String title,
  required String subtitle,
  required List<CatchFormStepReviewItem> items,
}) {
  return showCatchBottomSheet<int>(
    context: context,
    builder: (context) => CatchBottomSheetScaffold(
      title: title,
      subtitle: subtitle,
      child: CatchFormStepOverview(items: items),
    ),
  );
}

class CatchFormStepOverview extends StatelessWidget {
  const CatchFormStepOverview({
    super.key,
    required this.items,
    this.onStepSelected,
  });

  final List<CatchFormStepReviewItem> items;
  final ValueChanged<int>? onStepSelected;

  @override
  Widget build(BuildContext context) {
    return CatchFieldLanes.divided(
      children: [
        for (final item in items)
          CatchField.nav(
            key: ValueKey('catch-form-step-overview-${item.index}'),
            title: item.title,
            action: CatchBadge.functional(
              label: _statusLabel(context, item.status),
              tone: _statusTone(item.status),
            ),
            onTap: () {
              final callback = onStepSelected;
              if (callback != null) {
                callback(item.index);
              } else {
                Navigator.of(context).pop(item.index);
              }
            },
          ),
      ],
    );
  }
}

class CatchFormReviewBody extends StatelessWidget {
  const CatchFormReviewBody({
    super.key,
    required this.message,
    required this.items,
    required this.onStepSelected,
    this.summaryItems = const [],
  });

  final String message;
  final List<CatchFormStepReviewItem> items;
  final ValueChanged<int> onStepSelected;
  final List<CatchFormReviewSummaryItem> summaryItems;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return SingleChildScrollView(
      padding: CatchInsets.formStepBodyWithBottomActions,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            message,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          if (summaryItems.isNotEmpty) ...[
            gapH16,
            CatchFieldLanes.divided(
              children: [
                for (final item in summaryItems)
                  CatchField.read(
                    title: item.label,
                    body: item.value,
                    bodyMaxLines: 5,
                    icon: item.icon,
                  ),
              ],
            ),
          ],
          gapH16,
          CatchFormStepOverview(items: items, onStepSelected: onStepSelected),
        ],
      ),
    );
  }
}

class CatchFormReviewSummaryItem {
  const CatchFormReviewSummaryItem({
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;
}

String _statusLabel(BuildContext context, CatchFormStepStatus status) =>
    switch (status) {
      CatchFormStepStatus.complete => context.l10n.hostsWizardStatusComplete,
      CatchFormStepStatus.needsInformation =>
        context.l10n.hostsWizardStatusNeedsInformation,
      CatchFormStepStatus.optional => context.l10n.hostsWizardStatusOptional,
    };

CatchBadgeTone _statusTone(CatchFormStepStatus status) => switch (status) {
  CatchFormStepStatus.complete => CatchBadgeTone.success,
  CatchFormStepStatus.needsInformation => CatchBadgeTone.warning,
  CatchFormStepStatus.optional => CatchBadgeTone.neutral,
};
