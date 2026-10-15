part of 'catch_section.dart';

Widget _buildCollectionModule(
  BuildContext context, {
  required String title,
  required String? message,
  required String? emptyTitle,
  required String emptyMessage,
  required IconData? emptyIcon,
  required List<Widget> children,
  required Widget? leading,
  required String? actionLabel,
  required VoidCallback? onAction,
  required CatchButtonStatus actionStatus,
  required Widget? footer,
}) => _buildSectionModule(
  context,
  title: title,
  message: message,
  body: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (leading != null) ...[
        leading,
        const SizedBox(height: CatchSpacing.s3),
      ],
      if (children.isEmpty)
        CatchEmptyState(
          title: emptyTitle,
          message: emptyMessage,
          icon: emptyIcon,
          variant: CatchEmptyStateVariant.inline,
          padding: EdgeInsets.zero,
        )
      else
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const CatchDivider.section(),
          children[i],
        ],
    ],
  ),
  action: actionLabel == null
      ? null
      : CatchButton(
          label: actionLabel,
          onPressed: onAction,
          variant: CatchButtonVariant.primary,
          status: actionStatus,
          fullWidth: true,
        ),
  feedback: footer,
);
