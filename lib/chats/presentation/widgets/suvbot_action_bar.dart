import 'dart:async';

import 'package:catch_dating_app/chats/data/suvbot_repository.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_dock.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef SuvbotActionCallback = Future<void> Function(SuvbotActionItem action);
typedef SuvbotTextActionCallback =
    Future<void> Function(SuvbotActionItem action, String text);

const EdgeInsets _demoActionSheetPadding = EdgeInsets.fromLTRB(
  CatchSpacing.s3,
  0,
  CatchSpacing.s3,
  CatchSpacing.s4,
);

class SuvbotActionBar extends StatelessWidget {
  const SuvbotActionBar({
    super.key,
    required this.actions,
    required this.pending,
    required this.onAction,
    required this.onTextAction,
    required this.onRetry,
  });

  final AsyncValue<List<SuvbotActionItem>> actions;
  final bool pending;
  final SuvbotActionCallback onAction;
  final SuvbotTextActionCallback onTextAction;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return CatchBottomDock(
      child: actions.when(
        data: (items) => _buildSuvbotControls(
          context,
          actions: items,
          pending: pending,
          onAction: onAction,
          onTextAction: onTextAction,
        ),
        loading: _buildSuvbotLoadingControls,
        error: (_, _) => _buildSuvbotLoadError(context, onRetry: onRetry),
      ),
    );
  }
}

Widget _buildSuvbotControls(
  BuildContext context, {
  required List<SuvbotActionItem> actions,
  required bool pending,
  required SuvbotActionCallback onAction,
  required SuvbotTextActionCallback onTextAction,
}) {
  final t = CatchTokens.of(context);
  final byId = {for (final action in actions) action.id: action};
  final warmActions = [
    byId['warmSignupState'],
    byId['warmPostEventState'],
    byId['warmChatState'],
    byId['warmPaymentState'],
  ].whereType<SuvbotActionItem>().toList(growable: false);
  final resetActions = [
    byId['resetChats'],
    byId['resetBookings'],
    byId['resetNotifications'],
    byId['clearDemoState'],
  ].whereType<SuvbotActionItem>().toList(growable: false);
  final checkAction = byId['checkDemoState'];
  final refreshAction = byId['refreshDemoState'];
  final helpAction = byId['help'];
  final matchAction = byId['matchTesterByPhone'];

  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suvbot controls',
                  style: CatchTextStyles.sectionTitle(context, color: t.ink),
                ),
                gapH2,
                Text(
                  'No typing needed',
                  style: CatchTextStyles.statusLabel(context, color: t.ink2),
                ),
              ],
            ),
          ),
          if (helpAction != null)
            _buildCircleActionButton(
              context,
              icon: CatchIcons.helpOutlineRounded,
              label: helpAction.label,
              pending: pending,
              onPressed: () => unawaited(onAction(helpAction)),
            ),
        ],
      ),
      const SizedBox(height: CatchSpacing.s2),
      Row(
        children: [
          if (checkAction != null)
            Expanded(
              child: _buildSuvbotButton(
                context,
                label: checkAction.label,
                icon: _iconFor(checkAction.icon),
                pending: pending,
                prominent: true,
                onPressed: () => unawaited(onAction(checkAction)),
              ),
            ),
          if (checkAction != null && refreshAction != null)
            const SizedBox(width: CatchSpacing.s2),
          if (refreshAction != null)
            Expanded(
              child: _buildSuvbotButton(
                context,
                label: 'Refresh all',
                icon: _iconFor(refreshAction.icon),
                pending: pending,
                destructive: true,
                onPressed: () => unawaited(onAction(refreshAction)),
              ),
            ),
        ],
      ),
      if (warmActions.isNotEmpty) ...[
        const SizedBox(height: CatchSpacing.s3),
        _buildSuvbotGroupLabel(context, 'Create a test state'),
        const SizedBox(height: CatchSpacing.s1),
        Row(
          children: [
            for (final (index, action) in warmActions.indexed) ...[
              if (index > 0) const SizedBox(width: CatchSpacing.s1),
              Expanded(
                child: _buildSuvbotPresetButton(
                  context,
                  label: _shortWarmLabel(action),
                  icon: _iconFor(action.icon),
                  pending: pending,
                  onPressed: () => unawaited(onAction(action)),
                ),
              ),
            ],
          ],
        ),
      ],
      const SizedBox(height: CatchSpacing.s2),
      Row(
        children: [
          if (matchAction != null)
            Expanded(
              child: _buildSuvbotButton(
                context,
                label: matchAction.label,
                icon: _iconFor(matchAction.icon),
                pending: pending,
                onPressed: () => _showMatchTesterSheet(
                  context,
                  action: matchAction,
                  pending: pending,
                  onTextAction: onTextAction,
                ),
              ),
            ),
          if (matchAction != null && resetActions.isNotEmpty)
            const SizedBox(width: CatchSpacing.s2),
          if (resetActions.isNotEmpty)
            Expanded(
              child: _buildSuvbotButton(
                context,
                label: 'Reset...',
                icon: CatchIcons.cleaningServicesRounded,
                pending: pending,
                destructive: true,
                onPressed: () => _showResetSheet(
                  context,
                  actions: resetActions,
                  pending: pending,
                  onAction: onAction,
                ),
              ),
            ),
        ],
      ),
    ],
  );
}

Widget _buildSuvbotButton(
  BuildContext context, {
  required String label,
  required IconData icon,
  required bool pending,
  required VoidCallback onPressed,
  bool prominent = false,
  bool destructive = false,
}) {
  final t = CatchTokens.of(context);
  final colors = Theme.of(context).colorScheme;
  final foreground = destructive
      ? colors.error
      : prominent
      ? t.accent
      : t.ink;
  final background = destructive
      ? colors.errorContainer.withValues(
          alpha: CatchOpacity.suvbotDestructiveFill,
        )
      : prominent
      ? t.accent.withValues(alpha: CatchOpacity.subtleFill)
      : t.surface;

  return CatchButton(
    label: label,
    onPressed: pending ? null : onPressed,
    variant: destructive
        ? CatchButtonVariant.danger
        : CatchButtonVariant.secondary,
    size: CatchButtonSize.sm,
    fullWidth: true,
    isLoading: pending,
    icon: Icon(icon),
    foregroundColor: foreground,
    backgroundColor: background,
    borderColor: t.line,
  );
}

Widget _buildSuvbotPresetButton(
  BuildContext context, {
  required String label,
  required IconData icon,
  required bool pending,
  required VoidCallback onPressed,
}) {
  final t = CatchTokens.of(context);

  return CatchButton(
    label: label,
    onPressed: pending ? null : onPressed,
    variant: CatchButtonVariant.secondary,
    size: CatchButtonSize.sm,
    fullWidth: true,
    icon: Icon(icon),
    foregroundColor: t.ink,
    backgroundColor: t.surface,
    borderColor: t.line,
  );
}

Widget _buildCircleActionButton(
  BuildContext context, {
  required IconData icon,
  required String label,
  required bool pending,
  required VoidCallback onPressed,
}) {
  final t = CatchTokens.of(context);

  return Tooltip(
    message: label,
    child: CatchIconButton(
      size: CatchLayout.suvbotCircleActionExtent,
      background: t.surface,
      onTap: pending ? null : onPressed,
      child: Icon(icon, size: CatchIcon.md, color: pending ? t.ink3 : t.ink2),
    ),
  );
}

Widget _buildSuvbotGroupLabel(BuildContext context, String label) {
  return Text(label, style: CatchTextStyles.kicker(context));
}

Widget _buildSuvbotLoadingControls() {
  return const SizedBox(
    height: CatchLayout.suvbotLoadingControlsHeight,
    child: Center(child: CatchLoadingIndicator(strokeWidth: 2)),
  );
}

Widget _buildSuvbotLoadError(
  BuildContext context, {
  required VoidCallback onRetry,
}) {
  return _buildSuvbotButton(
    context,
    label: 'Reload controls',
    icon: CatchIcons.syncRounded,
    pending: false,
    onPressed: onRetry,
  );
}

Future<void> _showResetSheet(
  BuildContext context, {
  required List<SuvbotActionItem> actions,
  required bool pending,
  required SuvbotActionCallback onAction,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        child: CatchBottomSheetScaffold(
          title: 'Reset demo state',
          subtitle: 'These actions only touch demo-owned data.',
          child: Builder(
            builder: (context) {
              final t = CatchTokens.of(context);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final (index, action) in actions.indexed) ...[
                    SuvbotResetActionRow(
                      action: action,
                      pending: pending,
                      onTap: () {
                        Navigator.of(context).pop();
                        unawaited(onAction(action));
                      },
                    ),
                    if (index != actions.length - 1)
                      Divider(height: 1, color: t.line),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}

class SuvbotResetActionRow extends StatelessWidget {
  const SuvbotResetActionRow({
    super.key,
    required this.action,
    required this.pending,
    required this.onTap,
  });

  final SuvbotActionItem action;
  final bool pending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final tone = action.destructive ? t.danger : t.ink;
    return AnimatedOpacity(
      opacity: pending ? CatchOpacity.disabledControl : 1,
      duration: CatchMotion.fast,
      curve: CatchMotion.standardCurve,
      child: CatchSurface(
        tone: CatchSurfaceTone.transparent,
        radius: 0,
        borderWidth: 0,
        onTap: pending ? null : onTap,
        padding: const EdgeInsets.symmetric(
          horizontal: CatchSpacing.s1,
          vertical: CatchSpacing.s3,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: CatchSpacing.micro2),
              child: Icon(
                _iconFor(action.icon),
                color: tone,
                size: CatchIcon.row,
              ),
            ),
            gapW12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    action.label,
                    style: CatchTextStyles.fieldRowTitle(context, color: tone),
                  ),
                  gapH4,
                  Text(
                    action.description,
                    style: CatchTextStyles.supporting(context, color: t.ink2),
                  ),
                ],
              ),
            ),
            gapW12,
            Icon(
              CatchIcons.chevronRightRounded,
              color: action.destructive ? t.danger : t.ink3,
              size: CatchIcon.sm,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showMatchTesterSheet(
  BuildContext context, {
  required SuvbotActionItem action,
  required bool pending,
  required SuvbotTextActionCallback onTextAction,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => MatchTesterSheet(
      action: action,
      pending: pending,
      onTextAction: onTextAction,
    ),
  );
}

class MatchTesterSheet extends StatefulWidget {
  const MatchTesterSheet({
    super.key,
    required this.action,
    required this.pending,
    required this.onTextAction,
  });

  final SuvbotActionItem action;
  final bool pending;
  final SuvbotTextActionCallback onTextAction;

  @override
  State<MatchTesterSheet> createState() => _MatchTesterSheetState();
}

class _MatchTesterSheetState extends State<MatchTesterSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: _demoActionSheetPadding.copyWith(
        bottom: MediaQuery.viewInsetsOf(context).bottom + CatchSpacing.s4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Match tester', style: CatchTextStyles.titleL(context)),
          const SizedBox(height: CatchSpacing.s1),
          Text(
            'Enter an allowlisted beta tester phone number.',
            style: CatchTextStyles.supporting(context),
          ),
          const SizedBox(height: CatchSpacing.s3),
          CatchField.input(
            title: 'Phone number',
            controller: _controller,
            keyboardType: TextInputType.phone,
            autofocus: true,
            placeholder: '+919999999999',
          ),
          const SizedBox(height: CatchSpacing.s3),
          CatchButton(
            onPressed: widget.pending ? null : _submit,
            icon: Icon(CatchIcons.personAddAlt1Rounded),
            label: 'Create match',
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    Navigator.of(context).pop();
    unawaited(widget.onTextAction(widget.action, value));
  }
}

String _shortWarmLabel(SuvbotActionItem action) => switch (action.id) {
  'warmSignupState' => 'Signups',
  'warmPostEventState' => 'Post-event',
  'warmChatState' => 'Chats',
  'warmPaymentState' => 'Payments',
  _ => action.label,
};

IconData _iconFor(String icon) => switch (icon) {
  'refresh' => CatchIcons.refreshRounded,
  'clean' => CatchIcons.cleaningServicesRounded,
  'event' => CatchIcons.eventAvailableRounded,
  'flag' => CatchIcons.flagRounded,
  'chat' => CatchIcons.forumRounded,
  'payment' => CatchIcons.paymentsRounded,
  'chatReset' => CatchIcons.forumOutlined,
  'eventReset' => CatchIcons.eventBusyRounded,
  'notifications' => CatchIcons.notificationsOffRounded,
  'personAdd' => CatchIcons.personAddAlt1Rounded,
  'check' => CatchIcons.factCheckOutlined,
  'help' => CatchIcons.helpOutlineRounded,
  _ => CatchIcons.autoAwesomeRounded,
};
